# Package imports
from datetime import datetime
from typing import Optional, Dict, Any
import json
from collections import defaultdict


# Project imports
from .base_monitors import ProcessingMonitor


class MetricsMonitor(ProcessingMonitor):
    """
    Observer that collects performance and usage metrics.
    
    This observer tracks metrics such as:
    - Classification distribution
    - Processing times per agent
    - Error rates and types
    - Validation pass/fail rates
    """
    
    def __init__(self):
        """Initialize metrics storage."""
        self.metrics = {
            'classifications': defaultdict(int),
            'processing_times': defaultdict(list),
            'processing_counts': defaultdict(int),
            'errors': defaultdict(int),
            'validation_results': {'passed': 0, 'failed': 0},
            'validation_times': [],
            'total_requests': 0,
            'start_time': datetime.now()
        }
    
    def on_classification(self, classification: str, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        """Record classification metrics."""
        self.metrics['classifications'][classification] += 1
    
    def on_processing_start(self, agent_type: str, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        """Record processing start (for counting)."""
        self.metrics['processing_counts'][agent_type] += 1
    
    def on_processing_complete(self, agent_type: str, duration: float, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        """Record processing duration metrics."""
        self.metrics['processing_times'][agent_type].append(duration)
    
    def on_error(self, error: Exception, context: Dict[str, Any], timestamp: datetime, request_id: Optional[str] = None):
        """Record error metrics."""
        error_type = type(error).__name__
        self.metrics['errors'][error_type] += 1
    
    def on_validation_start(self, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        """Validation start increments total requests."""
        self.metrics['total_requests'] += 1

    
    def on_validation_complete(self, is_valid: bool, duration: float, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        """Record validation metrics."""
        if is_valid:
            self.metrics['validation_results']['passed'] += 1
        else:
            self.metrics['validation_results']['failed'] += 1
        self.metrics['validation_times'].append(duration)

    def on_event(self, event_name: str, timestamp: datetime, metadata: Optional[Dict[str, Any]] = None, request_id: Optional[str] = None):
        """Generic events are not tracked by this monitor."""
        pass
    
    def get_metrics_summary(self) -> Dict[str, Any]:
        """
        Get a summary of all collected metrics.
        
        Returns:
            Dictionary containing metrics summary with statistics
        """
        runtime = (datetime.now() - self.metrics['start_time']).total_seconds()
        
        # Calculate average processing times
        avg_processing_times = {}
        for agent_type, times in self.metrics['processing_times'].items():
            if times:
                avg_processing_times[agent_type] = {
                    'avg': sum(times) / len(times),
                    'min': min(times),
                    'max': max(times),
                    'count': len(times)
                }
        
        # Calculate validation statistics
        validation_stats = {}
        if self.metrics['validation_times']:
            validation_stats = {
                'avg_duration': sum(self.metrics['validation_times']) / len(self.metrics['validation_times']),
                'min_duration': min(self.metrics['validation_times']),
                'max_duration': max(self.metrics['validation_times']),
                'total_validations': len(self.metrics['validation_times'])
            }
        
        return {
            'runtime_seconds': runtime,
            'total_requests': self.metrics['total_requests'],
            'classifications': dict(self.metrics['classifications']),
            'processing_times': avg_processing_times,
            'processing_counts': dict(self.metrics['processing_counts']),
            'errors': dict(self.metrics['errors']),
            'validation_results': dict(self.metrics['validation_results']),
            'validation_stats': validation_stats,
            'requests_per_second': self.metrics['total_requests'] / runtime if runtime > 0 else 0
        }
    
    def export_metrics_json(self, filepath: str):
        """
        Export metrics to a JSON file.
        
        Args:
            filepath: Path where to save the metrics JSON
        """
        summary = self.get_metrics_summary()
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(summary, f, indent=2, ensure_ascii=False)
    
    def reset_metrics(self):
        """Reset all collected metrics."""
        self.metrics = {
            'classifications': defaultdict(int),
            'processing_times': defaultdict(list),
            'processing_counts': defaultdict(int),
            'errors': defaultdict(int),
            'validation_results': {'passed': 0, 'failed': 0},
            'validation_times': [],
            'total_requests': 0,
            'start_time': datetime.now()
        }

