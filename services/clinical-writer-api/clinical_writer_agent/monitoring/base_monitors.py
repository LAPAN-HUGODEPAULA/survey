"""
Observer Pattern Implementation for Logging and Monitoring

This module provides the observer pattern for tracking and monitoring
the clinical writer agent system's operations.
"""

# Package imports
from abc import ABC, abstractmethod
from datetime import datetime
from typing import Optional, Dict, Any

class ProcessingMonitor(ABC):
    """
    Abstract base class for processing observers.
    
    Observers can track events throughout the agent processing pipeline,
    including classification, processing start/completion, and errors.
    """
    
    @abstractmethod
    def on_classification(self, classification: str, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        pass
    
    @abstractmethod
    def on_processing_start(self, agent_type: str, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        pass
    
    @abstractmethod
    def on_processing_complete(self, agent_type: str, duration: float, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        pass
    
    @abstractmethod
    def on_error(self, error: Exception, context: Dict[str, Any], timestamp: datetime, request_id: Optional[str] = None):
        pass
    
    @abstractmethod
    def on_validation_start(self, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        pass
    
    @abstractmethod
    def on_validation_complete(self, is_valid: bool, duration: float, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        pass
    
    @abstractmethod
    def on_event(self, event_name: str, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        pass

class CompositeMonitor(ProcessingMonitor):
    """
    Composite monitor that delegates to multiple monitors.
    """
    
    def __init__(self, monitors: Optional[list[ProcessingMonitor]] = None):
        self.monitors = monitors or []
    
    def add_monitor(self, monitor: ProcessingMonitor):
        self.monitors.append(monitor)
    
    def on_classification(self, classification: str, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        for monitor in self.monitors:
            monitor.on_classification(classification, timestamp, metadata, request_id)
    
    def on_processing_start(self, agent_type: str, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        for monitor in self.monitors:
            monitor.on_processing_start(agent_type, timestamp, metadata, request_id)
    
    def on_processing_complete(self, agent_type: str, duration: float, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        for monitor in self.monitors:
            monitor.on_processing_complete(agent_type, duration, timestamp, metadata, request_id)
    
    def on_error(self, error: Exception, context: Dict[str, Any], timestamp: datetime, request_id: Optional[str] = None):
        for monitor in self.monitors:
            monitor.on_error(error, context, timestamp, request_id)
    
    def on_validation_start(self, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        for monitor in self.monitors:
            monitor.on_validation_start(timestamp, metadata, request_id)
    
    def on_validation_complete(self, is_valid: bool, duration: float, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        for monitor in self.monitors:
            monitor.on_validation_complete(is_valid, duration, timestamp, metadata, request_id)

    def on_event(self, event_name: str, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        for monitor in self.monitors:
            monitor.on_event(event_name, timestamp, metadata, request_id)