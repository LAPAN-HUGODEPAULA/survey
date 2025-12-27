import unittest
from unittest.mock import Mock, MagicMock, patch
from datetime import datetime
import logging
import sys
import os

from ..monitoring.base_monitors import ProcessingMonitor, CompositeMonitor
from ..monitoring.logging_monitor import LoggingMonitor
from ..monitoring.metrics_monitor import MetricsMonitor


class TestLoggingmonitor(unittest.TestCase):
    """Test Loggingmonitor functionality"""
    
    def setUp(self):
        """Set up test fixtures"""
        # Create a mock logger to capture log calls
        self.mock_logger = Mock(spec=logging.Logger)
        self.monitor = LoggingMonitor(logger=self.mock_logger)
        self.test_timestamp = datetime(2025, 11, 13, 10, 30, 0)
    
    def test_on_classification_logs_event(self):
        """Test that classification events are logged"""
        self.monitor.on_classification(
            "conversation",
            self.test_timestamp,
            {"input_length": 100}
        )
        
        # Verify log was called
        self.mock_logger.log.assert_called_once()
        call_args = self.mock_logger.log.call_args
        
        # Check log level and message
        self.assertEqual(call_args[0][0], logging.INFO)
        self.assertIn("conversation", call_args[0][1])
    
    def test_on_processing_start_logs_event(self):
        """Test that processing start events are logged"""
        self.monitor.on_processing_start(
            "ConversationProcessor",
            self.test_timestamp,
            {"input_length": 100}
        )
        
        self.mock_logger.log.assert_called_once()
        call_args = self.mock_logger.log.call_args
        self.assertIn("ConversationProcessor", call_args[0][1])
        self.assertIn("started", call_args[0][1])
    
    def test_on_processing_complete_logs_duration(self):
        """Test that processing completion logs duration"""
        self.monitor.on_processing_complete(
            "JsonProcessor",
            2.5,
            self.test_timestamp,
            {"success": True}
        )
        
        self.mock_logger.log.assert_called_once()
        call_args = self.mock_logger.log.call_args
        self.assertIn("2.5", call_args[0][1])
        self.assertIn("completed", call_args[0][1])
    
    def test_on_error_logs_with_error_level(self):
        """Test that errors are logged at ERROR level"""
        test_error = ValueError("Test error")
        context = {"location": "test_agent", "operation": "test_op"}
        
        self.monitor.on_error(test_error, context, self.test_timestamp)
        
        # Should use error method, not log
        self.mock_logger.error.assert_called_once()
        call_args = self.mock_logger.error.call_args
        self.assertIn("Test error", call_args[0][0])
    
    def test_on_validation_start_logs_event(self):
        """Test that validation start is logged"""
        self.monitor.on_validation_start(self.test_timestamp)
        
        self.mock_logger.log.assert_called_once()
        call_args = self.mock_logger.log.call_args
        self.assertIn("validation", call_args[0][1].lower())
    
    def test_on_validation_complete_logs_result(self):
        """Test that validation completion logs pass/fail"""
        # Test passed validation
        self.monitor.on_validation_complete(
            True, 0.5, self.test_timestamp, {"reason": "valid"}
        )
        call_args = self.mock_logger.log.call_args
        self.assertIn("passed", call_args[0][1])
        
        # Reset mock
        self.mock_logger.reset_mock()
        
        # Test failed validation
        self.monitor.on_validation_complete(
            False, 0.3, self.test_timestamp, {"reason": "invalid"}
        )
        call_args = self.mock_logger.log.call_args
        self.assertIn("failed", call_args[0][1])


class TestMetricsmonitor(unittest.TestCase):
    """Test Metricsmonitor metrics collection"""
    
    def setUp(self):
        """Set up test fixtures"""
        self.monitor = MetricsMonitor()
        self.test_timestamp = datetime(2025, 11, 13, 10, 30, 0)
    
    def test_classification_counting(self):
        """Test that classifications are counted correctly"""
        self.monitor.on_classification("conversation", self.test_timestamp)
        self.monitor.on_classification("json", self.test_timestamp)
        self.monitor.on_classification("conversation", self.test_timestamp)
        
        summary = self.monitor.get_metrics_summary()
        self.assertEqual(summary['classifications']['conversation'], 2)
        self.assertEqual(summary['classifications']['json'], 1)
        self.assertEqual(summary['total_requests'], 3)
    
    def test_processing_time_tracking(self):
        """Test that processing times are tracked"""
        self.monitor.on_processing_start("Agent1", self.test_timestamp)
        self.monitor.on_processing_complete("Agent1", 1.5, self.test_timestamp)
        self.monitor.on_processing_complete("Agent1", 2.0, self.test_timestamp)
        
        summary = self.monitor.get_metrics_summary()
        self.assertIn("Agent1", summary['processing_times'])
        self.assertEqual(summary['processing_times']['Agent1']['count'], 2)
        self.assertEqual(summary['processing_times']['Agent1']['avg'], 1.75)
        self.assertEqual(summary['processing_times']['Agent1']['min'], 1.5)
        self.assertEqual(summary['processing_times']['Agent1']['max'], 2.0)
    
    def test_error_counting(self):
        """Test that errors are counted by type"""
        error1 = ValueError("Test error 1")
        error2 = TypeError("Test error 2")
        error3 = ValueError("Test error 3")
        
        self.monitor.on_error(error1, {}, self.test_timestamp)
        self.monitor.on_error(error2, {}, self.test_timestamp)
        self.monitor.on_error(error3, {}, self.test_timestamp)
        
        summary = self.monitor.get_metrics_summary()
        self.assertEqual(summary['errors']['ValueError'], 2)
        self.assertEqual(summary['errors']['TypeError'], 1)
    
    def test_validation_statistics(self):
        """Test validation pass/fail statistics"""
        self.monitor.on_validation_complete(True, 0.5, self.test_timestamp)
        self.monitor.on_validation_complete(True, 0.6, self.test_timestamp)
        self.monitor.on_validation_complete(False, 0.3, self.test_timestamp)
        
        summary = self.monitor.get_metrics_summary()
        self.assertEqual(summary['validation_results']['passed'], 2)
        self.assertEqual(summary['validation_results']['failed'], 1)
        self.assertEqual(summary['validation_stats']['total_validations'], 3)
        self.assertAlmostEqual(summary['validation_stats']['avg_duration'], 0.467, places=2)
    
    def test_reset_metrics(self):
        """Test that metrics can be reset"""
        self.monitor.on_classification("conversation", self.test_timestamp)
        self.monitor.on_error(ValueError("Test"), {}, self.test_timestamp)
        
        self.monitor.reset_metrics()
        
        summary = self.monitor.get_metrics_summary()
        self.assertEqual(summary['total_requests'], 0)
        self.assertEqual(len(summary['classifications']), 0)
        self.assertEqual(len(summary['errors']), 0)
    
    def test_export_metrics_json(self):
        """Test exporting metrics to JSON file"""
        import tempfile
        import json
        
        self.monitor.on_classification("conversation", self.test_timestamp)
        
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.json') as f:
            filepath = f.name
        
        try:
            self.monitor.export_metrics_json(filepath)
            
            # Read and verify JSON
            with open(filepath, 'r') as f:
                data = json.load(f)
            
            self.assertEqual(data['total_requests'], 1)
            self.assertIn('conversation', data['classifications'])
        finally:
            os.unlink(filepath)


class TestCompositemonitor(unittest.TestCase):
    """Test Compositemonitor delegation"""
    
    def setUp(self):
        """Set up test fixtures"""
        self.monitor1 = Mock(spec=ProcessingMonitor)
        self.monitor2 = Mock(spec=ProcessingMonitor)
        self.composite = CompositeMonitor([self.monitor1, self.monitor2])
        self.test_timestamp = datetime(2025, 11, 13, 10, 30, 0)
    
    def test_add_monitor(self):
        """Test adding monitors dynamically"""
        monitor3 = Mock(spec=ProcessingMonitor)
        self.composite.add_monitor(monitor3)
        
        self.assertEqual(len(self.composite.monitors), 3)
        self.assertIn(monitor3, self.composite.monitors)
    
    def test_remove_monitor(self):
        """Test removing monitors"""
        self.composite.remove_monitor(self.monitor1)
        
        self.assertEqual(len(self.composite.monitors), 1)
        self.assertNotIn(self.monitor1, self.composite.monitors)
    
    def test_classification_delegates_to_all(self):
        """Test that classification events are sent to all monitors"""
        self.composite.on_classification("conversation", self.test_timestamp)
        
        self.monitor1.on_classification.assert_called_once_with(
            "conversation", self.test_timestamp, None
        )
        self.monitor2.on_classification.assert_called_once_with(
            "conversation", self.test_timestamp, None
        )
    
    def test_processing_start_delegates_to_all(self):
        """Test that processing start events are sent to all monitors"""
        metadata = {"test": "data"}
        self.composite.on_processing_start("Agent1", self.test_timestamp, metadata)
        
        self.monitor1.on_processing_start.assert_called_once_with(
            "Agent1", self.test_timestamp, metadata
        )
        self.monitor2.on_processing_start.assert_called_once_with(
            "Agent1", self.test_timestamp, metadata
        )
    
    def test_processing_complete_delegates_to_all(self):
        """Test that processing complete events are sent to all monitors"""
        self.composite.on_processing_complete("Agent1", 1.5, self.test_timestamp)
        
        self.monitor1.on_processing_complete.assert_called_once()
        self.monitor2.on_processing_complete.assert_called_once()
    
    def test_error_delegates_to_all(self):
        """Test that errors are sent to all monitors"""
        error = ValueError("Test")
        context = {"location": "test"}
        
        self.composite.on_error(error, context, self.test_timestamp)
        
        self.monitor1.on_error.assert_called_once_with(error, context, self.test_timestamp)
        self.monitor2.on_error.assert_called_once_with(error, context, self.test_timestamp)
    
    def test_monitor_failure_doesnt_break_others(self):
        """Test that if one monitor fails, others still get notified"""
        # Make monitor1 raise an exception
        self.monitor1.on_classification.side_effect = Exception("monitor1 failed")
        
        # Should not raise, and monitor2 should still be called
        self.composite.on_classification("conversation", self.test_timestamp)
        
        self.monitor2.on_classification.assert_called_once()
    
    def test_validation_start_delegates_to_all(self):
        """Test that validation start events are sent to all monitors"""
        self.composite.on_validation_start(self.test_timestamp)
        
        self.monitor1.on_validation_start.assert_called_once()
        self.monitor2.on_validation_start.assert_called_once()
    
    def test_validation_complete_delegates_to_all(self):
        """Test that validation complete events are sent to all monitors"""
        self.composite.on_validation_complete(True, 0.5, self.test_timestamp)
        
        self.monitor1.on_validation_complete.assert_called_once()
        self.monitor2.on_validation_complete.assert_called_once()


class TestmonitorIntegration(unittest.TestCase):
    """Integration tests for monitors with real implementations"""
    
    def test_logging_and_metrics_together(self):
        """Test using both logging and metrics monitors together"""
        # Create composite with both monitors
        logging_obs = LoggingMonitor()
        metrics_obs = MetricsMonitor()
        composite = CompositeMonitor([logging_obs, metrics_obs])
        
        timestamp = datetime.now()
        
        # Simulate a workflow
        composite.on_validation_start(timestamp)
        composite.on_validation_complete(True, 0.5, timestamp)
        composite.on_classification("conversation", timestamp)
        composite.on_processing_start("ConversationProcessor", timestamp)
        composite.on_processing_complete("ConversationProcessor", 2.0, timestamp)
        
        # Check metrics were collected
        summary = metrics_obs.get_metrics_summary()
        self.assertEqual(summary['total_requests'], 1)
        self.assertEqual(summary['classifications']['conversation'], 1)
        self.assertEqual(summary['validation_results']['passed'], 1)


if __name__ == '__main__':
    unittest.main()
