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
    def on_classification(self, classification: str, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None):
        """
        Called when input is classified.
        
        Args:
            classification: The classification type (e.g., 'conversation', 'json')
            timestamp: When the classification occurred
            metadata: Additional classification information
        """
        pass
    
    @abstractmethod
    def on_processing_start(self, agent_type: str, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None):
        """
        Called when an agent starts processing.
        
        Args:
            agent_type: The type of agent starting processing
            timestamp: When processing started
            metadata: Additional processing information
        """
        pass
    
    @abstractmethod
    def on_processing_complete(self, agent_type: str, duration: float, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None):
        """
        Called when an agent completes processing.
        
        Args:
            agent_type: The type of agent that completed
            duration: Processing duration in seconds
            timestamp: When processing completed
            metadata: Additional completion information
        """
        pass
    
    @abstractmethod
    def on_error(self, error: Exception, context: Dict[str, Any], timestamp: datetime):
        """
        Called when an error occurs during processing.
        
        Args:
            error: The exception that occurred
            context: Context information about where/when the error occurred
            timestamp: When the error occurred
        """
        pass
    
    @abstractmethod
    def on_validation_start(self, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None):
        """
        Called when input validation starts.
        
        Args:
            timestamp: When validation started
            metadata: Additional validation information
        """
        pass
    
    @abstractmethod
    def on_validation_complete(self, is_valid: bool, duration: float, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None):
        """
        Called when input validation completes.
        
        Args:
            is_valid: Whether validation passed
            duration: Validation duration in seconds
            timestamp: When validation completed
            metadata: Additional validation results
        """
        pass
    
    @abstractmethod
    def on_event(self, event_name: str, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None):
        """
        Called for generic events that require logging.
        
        Args:
            event_name: The name of the event
            timestamp: When the event occurred
            metadata: Additional event information
        """
        pass




class CompositeMonitor(ProcessingMonitor):
    """
    Composite monitor that delegates to multiple monitors.
    
    This allows multiple monitors to be notified of events simultaneously,
    enabling both logging and metrics collection at the same time.
    """
    
    def __init__(self, monitors: Optional[list[ProcessingMonitor]] = None):
        """
        Initialize composite monitor.
        
        Args:
            monitors: List of monitors to delegate to
        """
        self.monitors = monitors or []
    
    def add_monitor(self, monitor: ProcessingMonitor):
        """Add a monitor to the collection."""
        self.monitors.append(monitor)
    
    def remove_monitor(self, monitor: ProcessingMonitor):
        """Remove a monitor from the collection."""
        if monitor in self.monitors:
            self.monitors.remove(monitor)
    
    def on_classification(self, classification: str, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None):
        """Notify all monitors of classification."""
        for monitor in self.monitors:
            try:
                monitor.on_classification(classification, timestamp, metadata)
            except Exception as e:
                # Don't let one monitor failure break others
                print(f"Monitor {type(monitor).__name__} failed on classification: {e}")
    
    def on_processing_start(self, agent_type: str, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None):
        """Notify all monitors of processing start."""
        for monitor in self.monitors:
            try:
                monitor.on_processing_start(agent_type, timestamp, metadata)
            except Exception as e:
                print(f"Monitor {type(monitor).__name__} failed on processing start: {e}")
    
    def on_processing_complete(self, agent_type: str, duration: float, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None):
        """Notify all monitors of processing completion."""
        for monitor in self.monitors:
            try:
                monitor.on_processing_complete(agent_type, duration, timestamp, metadata)
            except Exception as e:
                print(f"Monitor {type(monitor).__name__} failed on processing complete: {e}")
    
    def on_error(self, error: Exception, context: Dict[str, Any], timestamp: datetime):
        """Notify all monitors of error."""
        for monitor in self.monitors:
            try:
                monitor.on_error(error, context, timestamp)
            except Exception as e:
                print(f"Monitor {type(monitor).__name__} failed on error: {e}")
    
    def on_validation_start(self, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None):
        """Notify all monitors of validation start."""
        for monitor in self.monitors:
            try:
                monitor.on_validation_start(timestamp, metadata)
            except Exception as e:
                print(f"Monitor {type(monitor).__name__} failed on validation start: {e}")
    
    def on_validation_complete(self, is_valid: bool, duration: float, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None):
        """Notify all monitors of validation completion."""
        for monitor in self.monitors:
            try:
                monitor.on_validation_complete(is_valid, duration, timestamp, metadata)
            except Exception as e:
                print(f"Monitor {type(monitor).__name__} failed on validation complete: {e}")

    def on_event(self, event_name: str, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None):
        """Notify all monitors of a generic event."""
        for monitor in self.monitors:
            try:
                monitor.on_event(event_name, timestamp, metadata)
            except Exception as e:
                print(f"Monitor {type(monitor).__name__} failed on event: {e}")