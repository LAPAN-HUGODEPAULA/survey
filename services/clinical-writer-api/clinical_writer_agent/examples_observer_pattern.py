#!/usr/bin/env python3
"""
Example demonstrating the Observer Pattern for Logging and Monitoring

This script shows how to use observers with the clinical writer system
to track processing events and collect metrics.
"""

# Package imports
import sys
import os
import logging

# Add directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__)))

from .agent_graph import create_graph, AgentState
from .monitoring.base_monitors import ProcessingMonitor, CompositeMonitor
from .monitoring.logging_monitor import LoggingMonitor
from .monitoring.metrics_monitor import MetricsMonitor


def example_with_default_observers():
    """Example using the default observer configuration"""
    print("\n=== Example 1: Using Default Observers ===\n")
    
    from .agent_graph import clinical_writer_graph, _default_observer
    
    # Test with conversation input
    conversation_input = """
    Paciente: Doutor, estou com dor de cabeça há 3 dias.
    Médico: Há quanto tempo começou?
    Paciente: Começou na segunda-feira de manhã.
    Médico: A dor é constante ou intermitente?
    Paciente: É constante, e piora à noite.
    """
    
    state = AgentState(
        input_content=conversation_input,
        observer=_default_observer
    )
    
    result = clinical_writer_graph.invoke(state)
    
    print("\nProcessing Result:")
    print(f"Classification: {result.get('classification')}")
    print(f"Medical Record Generated: {len(result.get('medical_record', ''))} characters")
    
    # Get metrics from the default observer
    for monitor in _default_observer.monitors:
        if hasattr(monitor, 'get_metrics_summary'):
            print("\n=== Metrics Summary ===")
            summary = monitor.get_metrics_summary() # pyright: ignore[reportAttributeAccessIssue]
            print(f"Total Requests: {summary['total_requests']}")
            print(f"Classifications: {summary['classifications']}")
            print(f"Validation Results: {summary['validation_results']}")


def example_with_custom_logging():
    """Example with custom logging configuration"""
    print("\n\n=== Example 2: Custom Logging Configuration ===\n")
    
    # Create custom logger with DEBUG level
    custom_logger = logging.getLogger("CustomClinicalWriter")
    custom_logger.setLevel(logging.DEBUG)
    
    handler = logging.StreamHandler()
    handler.setLevel(logging.DEBUG)
    formatter = logging.Formatter(
        '%(asctime)s - [%(levelname)s] - %(message)s',
        datefmt='%H:%M:%S'
    )
    handler.setFormatter(formatter)
    custom_logger.addHandler(handler)
    
    # Create observer with custom logger
    logging_obs = LoggingMonitor(logger=custom_logger, log_level=logging.DEBUG)
    
    # Create graph with custom observer
    graph = create_graph(logging_obs)
    
    # Test input
    json_input = """{
        "chief_complaint": "Dor de cabeça",
        "history": "Paciente relata cefaleia há 3 dias",
        "duration": "3 dias"
    }"""
    
    state = AgentState(
        input_content=json_input,
        observer=logging_obs
    )
    
    result = graph.invoke(state)
    print(f"\nClassification: {result.get('classification')}")


def example_metrics_only():
    """Example using only metrics observer"""
    print("\n\n=== Example 3: Metrics Only (No Logging) ===\n")
    
    # Create metrics-only observer
    metrics_obs = MetricsMonitor()
    
    # Create graph
    graph = create_graph(metrics_obs)
    
    # Process multiple inputs to collect metrics
    test_inputs = [
        "Paciente com dor abdominal há 2 dias",
        '{"chief_complaint": "Febre", "duration": "5 dias"}',
        "Consulta sobre tontura e náusea",
        "😊😊😊",  # This will be flagged
        "Paciente idoso com hipertensão controlada"
    ]
    
    print("Processing multiple inputs...")
    for i, input_text in enumerate(test_inputs, 1):
        state = AgentState(
            input_content=input_text,
            observer=metrics_obs
        )
        result = graph.invoke(state)
        print(f"{i}. {result.get('classification')}")
    
    # Get metrics summary
    print("\n=== Final Metrics Summary ===")
    summary = metrics_obs.get_metrics_summary()
    
    print(f"\nTotal Requests: {summary['total_requests']}")
    print(f"\nClassifications:")
    for cls, count in summary['classifications'].items():
        print(f"  - {cls}: {count}")
    
    print(f"\nValidation Results:")
    print(f"  - Passed: {summary['validation_results']['passed']}")
    print(f"  - Failed: {summary['validation_results']['failed']}")
    
    if summary['validation_stats']:
        print(f"\nValidation Statistics:")
        print(f"  - Average Duration: {summary['validation_stats']['avg_duration']:.4f}s")
        print(f"  - Total Validations: {summary['validation_stats']['total_validations']}")
    
    if summary['processing_times']:
        print(f"\nProcessing Times by Agent:")
        for agent, times in summary['processing_times'].items():
            print(f"  - {agent}:")
            print(f"    Average: {times['avg']:.4f}s")
            print(f"    Min: {times['min']:.4f}s")
            print(f"    Max: {times['max']:.4f}s")
            print(f"    Count: {times['count']}")
    
    # Export to JSON
    output_file = "/tmp/clinical_writer_metrics.json"
    metrics_obs.export_metrics_json(output_file)
    print(f"\nMetrics exported to: {output_file}")


def example_without_observers():
    """Example running without any observers"""
    print("\n\n=== Example 4: Running Without Observers ===\n")
    
    # Create graph without observer
    graph = create_graph(observer=None)
    
    state = AgentState(
        input_content="Simple test without monitoring",
        observer=None
    )
    
    result = graph.invoke(state)
    print(f"Classification: {result.get('classification')}")
    print("No logging or metrics collected")


def example_composite_custom():
    """Example with multiple custom observers"""
    print("\n\n=== Example 5: Composite with Multiple Observers ===\n")
    
    # Create multiple observers
    logging_obs = LoggingMonitor()
    metrics_obs = MetricsMonitor()
    
    # Combine them
    composite = CompositeMonitor([logging_obs, metrics_obs])
    
    # Create graph
    graph = create_graph(composite)
    
    state = AgentState(
        input_content="Paciente apresenta sintomas de gripe",
        observer=composite
    )
    
    result = graph.invoke(state)
    
    print(f"\nClassification: {result.get('classification')}")
    
    # Both logging and metrics are collected
    summary = metrics_obs.get_metrics_summary()
    print(f"Total Requests: {summary['total_requests']}")


if __name__ == "__main__":
    print("=" * 70)
    print("Observer Pattern Examples for Clinical Writer AI")
    print("=" * 70)
    
    try:
        # Run all examples
        example_with_default_observers()
        example_with_custom_logging()
        example_metrics_only()
        example_without_observers()
        example_composite_custom()
        
        print("\n" + "=" * 70)
        print("All examples completed successfully!")
        print("=" * 70)
        
    except Exception as e:
        print(f"\nError running examples: {e}")
        import traceback
        traceback.print_exc()
