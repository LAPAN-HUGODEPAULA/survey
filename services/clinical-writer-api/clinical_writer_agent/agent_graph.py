# Package imports
from langgraph.graph import StateGraph, END
from typing import Optional

# Project imports
from .agents.agent_state import AgentState
from .agents.input_validator_agent import InputValidatorAgent
from .agents.deterministic_router_agent import DeterministicRouterAgent
from .agents.writer_nodes import ConsultWriterNode, Survey7WriterNode, FullIntakeWriterNode
from .agents.other_inputs_handler_agent import OtherInputHandlerAgent

from .monitoring.base_monitors import CompositeMonitor, ProcessingMonitor
from .monitoring.logging_monitor import LoggingMonitor
from .monitoring.metrics_monitor import MetricsMonitor


def create_graph(
    observer: Optional[ProcessingMonitor] = None,
    *,
    conversation_llm=None,
    json_llm=None,
):
    """
    Create and configure the LangGraph workflow for clinical record generation.
    
    Args:
        observer: Optional observer for monitoring and logging to attach to the compiled graph.
        conversation_llm: Optional LLM instance to inject into the conversation processor.
        json_llm: Optional LLM instance to inject into the JSON processor.
    
    Returns:
        Compiled LangGraph workflow
    """
    workflow = StateGraph(AgentState)

    # Add nodes
    workflow.add_node("validate_input", InputValidatorAgent().validate)
    workflow.add_node(
        "route_input",
        DeterministicRouterAgent({"consult", "survey7", "full_intake"}).route,
    )
    workflow.add_node("process_consult", ConsultWriterNode(llm_model=conversation_llm).process)
    workflow.add_node("process_survey7", Survey7WriterNode(llm_model=json_llm).process)
    workflow.add_node("process_full_intake", FullIntakeWriterNode(llm_model=json_llm).process)
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
            "consult": "process_consult",
            "survey7": "process_survey7",
            "full_intake": "process_full_intake",
            "invalid": "handle_other",
        },
    )

    # Define normal edges
    workflow.add_edge("process_consult", END)
    workflow.add_edge("process_survey7", END)
    workflow.add_edge("process_full_intake", END)
    workflow.add_edge("handle_other", END)

    compiled_graph = workflow.compile()

    # Attach the observer for downstream consumers (e.g., FastAPI dependency)
    # so they can reuse the same monitor instance when invoking the graph.
    if observer:
        setattr(compiled_graph, "observer", observer)

    return compiled_graph


def create_default_observer() -> CompositeMonitor:
    """
    Create a default composite observer with logging and metrics.
    
    Returns:
        CompositeObserver with logging and metrics observers
    """
    composite = CompositeMonitor()
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
