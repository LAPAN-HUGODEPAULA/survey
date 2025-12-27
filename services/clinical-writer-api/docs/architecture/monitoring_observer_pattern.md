# Monitoring and Logging with the Observer Pattern

The Clinical Writer AI system uses the **Observer Pattern** to provide comprehensive monitoring and logging capabilities. This allows for a decoupled architecture where the core application logic can be observed by one or more monitoring components without being tightly coupled to them.

## Architecture

The monitoring system is built around the `ProcessingMonitor` abstract base class, which defines the interface for all observers.

### Core Components

*   **`ProcessingMonitor` (ABC):** Located in `monitoring/base_monitors.py`, this abstract class defines the events that can be observed, such as `on_classification`, `on_processing_start`, `on_error`, etc.
*   **`LoggingMonitor`:** A concrete implementation in `monitoring/logging_monitor.py` that logs all events to a structured logger.
*   **`MetricsMonitor`:** A concrete implementation in `monitoring/metrics_monitor.py` that collects performance and usage metrics.
*   **`CompositeMonitor`:** A special monitor that holds a list of other monitors and delegates all events to them. This allows for using both logging and metrics at the same time.

### Key Events Tracked

| Event | Triggered By | Information Captured |
|---|---|---|
| `on_validation_start` | InputValidator | Timestamp, metadata |
| `on_validation_complete` | InputValidator | Duration, pass/fail, reason |
| `on_classification` | InputValidator | Classification type, metadata |
| `on_processing_start` | Any Agent | Agent type, timestamp, metadata |
| `on_processing_complete` | Any Agent | Agent type, duration, success |
| `on_error` | Any Agent | Exception, context, stack trace |

## How to Use

The monitoring system is designed to be easy to use. The default graph is pre-configured with a shared `CompositeMonitor` that includes both logging and metrics.

### Default Usage

```python
from clinical_writer_agent.agent_graph import clinical_writer_graph, get_shared_observer

state = {
    "input_content": "Your input here...",
    "observer": get_shared_observer(),
}
result = clinical_writer_graph.invoke(state)
```

### Accessing Metrics

A `/metrics` endpoint is available to get a real-time summary of the collected metrics.

```bash
curl http://localhost:8000/metrics
```

### Custom Observer Configuration

You can create your own observer configuration if you need more control.

```python
from clinical_writer_agent.monitoring import CompositeMonitor, LoggingMonitor, MetricsMonitor
from clinical_writer_agent.agent_graph import create_graph
import logging

# Create a composite monitor with custom settings
composite = CompositeMonitor([
    LoggingMonitor(log_level=logging.DEBUG),
    MetricsMonitor(),
])

# Create a graph with the custom monitor
graph = create_graph(observer=composite)
```

## Creating a Custom Observer

You can create a custom observer by inheriting from `ProcessingMonitor` and implementing the desired event methods.

```python
from clinical_writer_agent.monitoring import ProcessingMonitor
from datetime import datetime
from typing import Optional, Dict, Any

class MyCustomObserver(ProcessingMonitor):
    def on_classification(self, classification: str, timestamp: datetime, 
                         metadata: Optional[Dict[str, Any]] = None):
        print(f"Custom observer saw classification: {classification}")
    
    # Implement other methods as needed...
```
