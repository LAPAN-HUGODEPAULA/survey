# Package imports
from langgraph.graph import StateGraph, END
from typing import Optional

# Project imports
from .agents.agent_state import AgentState
from .agents.input_validator_agent import InputValidatorAgent
from .agents.deterministic_router_agent import DeterministicRouterAgent
from .agents.context_loader_agent import ContextLoaderAgent
from .agents.clinical_analyzer_agent import ClinicalAnalyzerAgent
from .agents.persona_writer_agent import PersonaWriterAgent
from .agents.reflector_node import ReflectorNode
from .agents.other_inputs_handler_agent import OtherInputHandlerAgent
from .monitoring.base_monitors import CompositeMonitor, ProcessingMonitor
from .monitoring.logging_monitor import LoggingMonitor
from .monitoring.metrics_monitor import MetricsMonitor
from .monitoring.progress_monitor import ProgressMonitor
from .monitoring.progress_tracker import ProgressTracker
from .prompt_registry import create_prompt_registry

_progress_tracker = ProgressTracker()


def create_graph(
    observer: Optional[ProcessingMonitor] = None,
    *,
    conversation_llm=None,
    json_llm=None,
    critique_llm=None,
    prompt_registry=None,
):
    """
    Create and configure the LangGraph workflow for clinical record generation.
    
    Args:
        observer: Optional observer for monitoring and logging to attach to the compiled graph.
        conversation_llm: Optional LLM instance to inject into the conversation processor.
        json_llm: Optional LLM instance to inject into the JSON processor.
        critique_llm: Optional higher-order LLM instance to inject into the reflection processor.
    
    Returns:
        Compiled LangGraph workflow
    """
    workflow = StateGraph(AgentState)

    resolved_prompt_registry = prompt_registry or create_prompt_registry()

    # Add nodes
    workflow.add_node("validate_input", InputValidatorAgent().validate)
    workflow.add_node(
        "route_input",
        DeterministicRouterAgent({"consult", "survey7", "full_intake"}).route,
    )
    workflow.add_node("context_loader", ContextLoaderAgent(resolved_prompt_registry).load)
    workflow.add_node(
        "clinical_analyzer",
        ClinicalAnalyzerAgent(
            conversation_llm=conversation_llm,
            json_llm=json_llm,
        ).analyze,
    )
    workflow.add_node(
        "persona_writer",
        PersonaWriterAgent(
            conversation_llm=conversation_llm,
            json_llm=json_llm,
        ).write,
    )
    workflow.add_node(
        "reflector",
        ReflectorNode(
            critique_llm=critique_llm,
        ).reflect,
    )
    workflow.add_node("handle_other", OtherInputHandlerAgent().handle)

    # Set entry point
    workflow.set_entry_point("validate_input")

    # Route validated inputs to deterministic routing; short-circuit flagged content.
    workflow.add_conditional_edges(
        "validate_input",
        lambda state: state["validation_status"],
        {
            "flagged": "handle_other",
            "validated": "route_input",
        },
    )

    # Define conditional edges based on input_type
    workflow.add_conditional_edges(
        "route_input",
        lambda state: state["input_type"],
        {
            "consult": "context_loader",
            "survey7": "context_loader",
            "full_intake": "context_loader",
            "invalid": "handle_other",
        },
    )

    workflow.add_conditional_edges(
        "context_loader",
        lambda state: "error" if state.get("error_message") else "ok",
        {
            "ok": "clinical_analyzer",
            "error": "handle_other",
        },
    )
    workflow.add_conditional_edges(
        "clinical_analyzer",
        lambda state: "error" if state.get("error_message") else "ok",
        {
            "ok": "persona_writer",
            "error": "handle_other",
        },
    )
    workflow.add_conditional_edges(
        "persona_writer",
        lambda state: "error" if state.get("error_message") else "ok",
        {
            "ok": "reflector",
            "error": "handle_other",
        },
    )
    workflow.add_conditional_edges(
        "reflector",
        lambda state: _resolve_reflection_route(state),
        {
            "pass": END,
            "retry": "persona_writer",
            "error": "handle_other",
        },
    )
    workflow.add_edge("handle_other", END)

    compiled_graph = workflow.compile()

    # Attach the observer for downstream consumers (e.g., FastAPI dependency)
    # so they can reuse the same monitor instance when invoking the graph.
    if observer:
        setattr(compiled_graph, "observer", observer)

    return compiled_graph


def _resolve_reflection_route(state: AgentState) -> str:
    """Return the next workflow step after reflection."""
    if state.get("error_message"):
        return "error"
    if state.get("reflection_status") == "passed":
        return "pass"
    if state.get("reflection_status") == "failed":
        return "retry"
    return "error"


def create_default_observer() -> CompositeMonitor:
    """
    Create a default composite observer with logging and metrics.
    
    Returns:
        CompositeObserver with logging and metrics observers
    """
    composite = CompositeMonitor()
    composite.add_monitor(ProgressMonitor(_progress_tracker))
    composite.add_monitor(LoggingMonitor())
    composite.add_monitor(MetricsMonitor())
    return composite


def get_metrics_monitor(observer: ProcessingMonitor) -> MetricsMonitor:
    """Extract the metrics monitor from a processing monitor."""
    if isinstance(observer, MetricsMonitor):
        return observer
    if isinstance(observer, CompositeMonitor):
        for monitor in observer.monitors:
            if isinstance(monitor, MetricsMonitor):
                return monitor
    raise ValueError("Metrics monitor not found in observer")


# Compile the graph once with default observer
_default_observer = create_default_observer()
clinical_writer_graph = create_graph(_default_observer)


def get_shared_observer() -> CompositeMonitor:
    """Return the shared composite observer used by the compiled graph."""
    return _default_observer


def get_progress_tracker() -> ProgressTracker:
    """Return the shared in-memory progress tracker."""
    return _progress_tracker
