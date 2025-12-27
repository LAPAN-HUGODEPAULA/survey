# Monitoring and Logging

The Clinical Writer AI system includes a robust monitoring and logging framework based on the **Observer Pattern**. This provides detailed insights into the system's behavior, performance, and health.

## Key Features

*   **Structured Logging:** All significant events in the processing pipeline are logged with detailed context, making it easy to trace and debug requests.
*   **Performance Metrics:** Key performance indicators (KPIs) such as processing times, request rates, and error rates are collected and exposed via an API endpoint.
*   **Decoupled Architecture:** The monitoring system is decoupled from the core application logic, allowing for easy extension and customization without modifying the main workflow.

## Available Monitors

The system ships with two primary monitoring components:

*   **`LoggingMonitor` (`monitoring/logging_monitor.py`):** Captures and logs a detailed, structured audit trail of all processing events.
*   **`MetricsMonitor` (`monitoring/metrics_monitor.py`):** Collects and aggregates performance and usage metrics.

These are combined using a `CompositeMonitor` (`monitoring/base_monitors.py`), which delegates events to all registered monitors so logging and metrics run side by side.

## How to Use

By default, the application runs with a shared `CompositeMonitor` wired into the graph, so every request flows through the same logging/metrics instance. Logs go to the console, and metrics are exposed live via the `/metrics` API endpoint.

```bash
# Get real-time metrics
curl http://localhost:8000/metrics
```

For more detailed information on the architecture and how to create custom observers, please see the [Monitoring with the Observer Pattern](./architecture/monitoring_observer_pattern.md) documentation.
