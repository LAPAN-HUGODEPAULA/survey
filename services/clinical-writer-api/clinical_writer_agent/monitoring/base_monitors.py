"""
Observer Pattern Implementation for Logging and Monitoring

This module provides the observer pattern for tracking and monitoring
the clinical writer agent system's operations.
"""

# Package imports
from abc import ABC
from datetime import datetime
from typing import Optional, Dict, Any

class ProcessingMonitor(ABC):
    """
    Abstract base class for processing observers.
    
    Observers can track events throughout the agent processing pipeline,
    including classification, processing start/completion, and errors.
    """
    
    def on_classification(self, classification: str, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        del classification, timestamp, metadata, request_id

    def on_processing_start(self, agent_type: str, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        del agent_type, timestamp, metadata, request_id

    def on_processing_complete(self, agent_type: str, duration: float, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        del agent_type, duration, timestamp, metadata, request_id

    def on_error(self, error: Exception, context: Dict[str, Any], timestamp: datetime, request_id: Optional[str] = None):
        del error, context, timestamp, request_id

    def on_validation_start(self, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        del timestamp, metadata, request_id

    def on_validation_complete(self, is_valid: bool, duration: float, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        del is_valid, duration, timestamp, metadata, request_id

    def on_event(self, event_name: str, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        del event_name, timestamp, metadata, request_id

class CompositeMonitor(ProcessingMonitor):
    """
    Composite monitor that delegates to multiple monitors.
    """
    
    def __init__(self, monitors: Optional[list[ProcessingMonitor]] = None):
        self.monitors = monitors or []
    
    def add_monitor(self, monitor: ProcessingMonitor):
        self.monitors.append(monitor)
    
    def remove_monitor(self, monitor: ProcessingMonitor):
        if monitor in self.monitors:
            self.monitors.remove(monitor)
    
    def on_classification(self, classification: str, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        for monitor in self.monitors:
            try:
                monitor.on_classification(classification, timestamp, metadata, request_id)
            except Exception:
                pass

    def on_processing_start(self, agent_type: str, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        for monitor in self.monitors:
            try:
                monitor.on_processing_start(agent_type, timestamp, metadata, request_id)
            except Exception:
                pass

    def on_processing_complete(self, agent_type: str, duration: float, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        for monitor in self.monitors:
            try:
                monitor.on_processing_complete(agent_type, duration, timestamp, metadata, request_id)
            except Exception:
                pass

    def on_error(self, error: Exception, context: Dict[str, Any], timestamp: datetime, request_id: Optional[str] = None):
        for monitor in self.monitors:
            try:
                monitor.on_error(error, context, timestamp, request_id)
            except Exception:
                pass

    def on_validation_start(self, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        for monitor in self.monitors:
            try:
                monitor.on_validation_start(timestamp, metadata, request_id)
            except Exception:
                pass

    def on_validation_complete(self, is_valid: bool, duration: float, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        for monitor in self.monitors:
            try:
                monitor.on_validation_complete(is_valid, duration, timestamp, metadata, request_id)
            except Exception:
                pass

    def on_event(self, event_name: str, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        for monitor in self.monitors:
            try:
                monitor.on_event(event_name, timestamp, metadata, request_id)
            except Exception:
                pass
