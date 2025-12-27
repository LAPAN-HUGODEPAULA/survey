# Package imports
from langgraph.graph import StateGraph, END
from typing import Optional

# Project imports
from .agent_config import AgentConfig
from .agents.agent_state import AgentState
from .agents.classification_agent import ClassificationAgent
from .agents.input_validator_agent import InputValidatorAgent
from .agents.conversation_processor_agent import ConversationProcessorAgent
from .agents.json_processor_agent import JsonProcessorAgent
from .agents.other_inputs_handler_agent import OtherInputHandlerAgent

from .monitoring.base_monitors import CompositeMonitor, ProcessingMonitor
from .monitoring.logging_monitor import LoggingMonitor
from .monitoring.metrics_monitor import MetricsMonitor


def create_graph(
    observer: Optional[ProcessingMonitor] = None,
    *,
    conversation_llm=None,
    json_llm=None,
    judge_llm=None,
):
    """
    Create and configure the LangGraph workflow for clinical record generation.
    
    Args:
        observer: Optional observer for monitoring and logging to attach to the compiled graph.
        conversation_llm: Optional LLM instance to inject into the conversation processor.
        json_llm: Optional LLM instance to inject into the JSON processor.
        judge_llm: Optional LLM instance used as the appropriateness judge during validation.
    
    Returns:
        Compiled LangGraph workflow
    """
    workflow = StateGraph(AgentState)

    # Add nodes
    workflow.add_node("validate_input", InputValidatorAgent(llm_judge=judge_llm).validate)
    workflow.add_node("classify_input", ClassificationAgent().classify)
    workflow.add_node("process_conversation", ConversationProcessorAgent(llm_model=conversation_llm).process)
    workflow.add_node("process_json", JsonProcessorAgent(llm_model=json_llm).process)
    workflow.add_node("handle_other", OtherInputHandlerAgent().handle)

    # Set entry point
    workflow.set_entry_point("validate_input")

    # Route validated inputs to classification; short-circuit flagged content.
    workflow.add_conditional_edges(
        "validate_input",
        lambda state: state["classification"],
        {
            AgentConfig.CLASSIFICATION_FLAGGED: "handle_other",
            AgentConfig.CLASSIFICATION_VALIDATED: "classify_input",
        },
    )

    # Define conditional edges based on classification
    workflow.add_conditional_edges(
        "classify_input",
        lambda state: state["classification"],
        {
            AgentConfig.CLASSIFICATION_CONVERSATION: "process_conversation",
            AgentConfig.CLASSIFICATION_JSON: "process_json",
            AgentConfig.CLASSIFICATION_INAPPROPRIATE: "handle_other",
            AgentConfig.CLASSIFICATION_OTHER: "handle_other",
        },
    )

    # Define normal edges
    workflow.add_edge("process_conversation", END)
    workflow.add_edge("process_json", END)
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
