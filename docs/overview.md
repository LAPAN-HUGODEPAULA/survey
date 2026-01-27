# Software Overview

## Context

Visual hypersensitivity represents a critical transdiagnostic marker across neurodevelopmental disorders (NDDs) and mental health conditions. Recent research demonstrates that visual system sensitivity alterations are deeply connected to conditions such as Autism Spectrum Disorder (ASD), Attention-Deficit/Hyperactivity Disorder (ADHD), and dyslexia, serving as vital indicators of neurological health. The Cardiff Hypersensitivity Scale-Visual (CHYPS-V) has been validated in English as a transdiagnostic instrument for assessing four dimensions of visual hypersensitivity: photophobia, pattern aversion, flicker sensitivity, and intense visual environments. However, no Brazilian Portuguese version exists with local normative parameters for clinical application in Brazil's diverse population.

This software system emerges as a technological component of the broader research project "Development and Validation of Innovative Technologies and Methods for Visual Function Assessment in the Diagnosis and Treatment of Neurodevelopmental Disorders" which aims to revolutionize NDD diagnosis through visual function assessment innovations.

## Problem statement

Current diagnostic approaches for visual hypersensitivity in neurodevelopmental disorders face significant limitations in the Brazilian context:

- **Lack of validated instruments**: No standardized, culturally-adapted tools exist for screening visual hypersensitivity across transdiagnostic populations in Brazil
- **Fragmented assessment workflows**: Existing clinical practices rely on subjective observations and disconnected evaluation methods without systematic documentation
- **Accessibility barriers**: Traditional assessment methods require specialized equipment and trained professionals, limiting early detection and intervention opportunities
- **Documentation inefficiency**: Clinical narratives and patient assessments are manually transcribed, leading to inconsistent documentation quality and delayed diagnostic processes
- **Research-practice gap**: Validated research instruments like CHYPS-V remain inaccessible to Brazilian clinicians due to language barriers and lack of local normative data

These challenges result in delayed diagnoses, inconsistent clinical documentation, and limited accessibility to early screening for visual hypersensitivity conditions that significantly impact quality of life, learning outcomes, and psychoemotional well-being.

## Purpose

This software system provides an integrated technological platform designed to support the assessment, documentation, and diagnostic workflow for visual hypersensitivity in neurodevelopmental disorders. The system serves three primary purposes:

1. **Enable early screening**: Provide accessible preliminary screening tools for individuals to identify potential visual hypersensitivity symptoms and facilitate appropriate professional referral
2. **Support clinical assessment**: Equip healthcare and education professionals with validated, research-backed questionnaires and structured assessment tools for comprehensive evaluation
3. **Streamline clinical documentation**: Automate the transformation of clinical conversations and assessment data into standardized medical records using AI-powered narrative processing

The system operates as an assistant tool that enhances professional diagnostic capabilities rather than replacing clinical judgment. It aims to bridge the gap between research validation and clinical practice by making evidence-based assessment tools accessible while maintaining rigorous scientific standards.

## Components

The system consists of three interconnected web applications sharing a common multi-agent AI architecture and MongoDB document database:

### 1. Survey-Patient Application

A patient-facing screening tool designed for preliminary assessment of visual hypersensitivity symptoms. This application features:

- A concise 7-question screening questionnaire focused on identifying signs of visual hypersensitivity and neurodevelopmental disorders
- Immediate generation of a simplified patient summary report with visual indicators of potential concerns
- Automated medical referral document creation for professional follow-up evaluation
- No patient identification required during initial screening to reduce barriers to access
- Responsive interface compliant with WCAG 2.1 Level AA accessibility standards

### 2. Survey-Frontend Application

A professional-facing assessment platform for qualified screeners (healthcare and education professionals) featuring:

- Access to validated research-backed questionnaires including the CHYPS-Br (20-item Brazilian-adapted version)
- Patient registry management with unique identifiers for longitudinal tracking
- Screener credential management system requiring professional registration numbers from recognized councils (e.g., Federal Medical Council, Federal Psychology Council)
- Medical report generation with structured templates reviewed by medical supervision team
- Patient history tracking capabilities for monitoring assessment progression over time
- Role-based access control ensuring only qualified professionals can generate clinical documentation

### 3. Clinical-Narrative Application

A conversational documentation tool that transforms clinician-patient interactions into structured medical records:

- Transcript processing of clinical conversations between screeners and patients
- Natural language processing for extracting relevant clinical information and observations
- Automated generation of formal medical documentation following standardized templates
- Research-focused data collection with anonymized medical record registry storage
- Integration with the multi-agent AI system for context-aware narrative interpretation

### 4. Clinical Writer AI Multi-Agent System

A centralized AI processing engine that powers all three applications through specialized agent workflows:

- **InputValidatorAgent**: Performs structural validation, data sanitization, and payload verification
- **DeterministicRouterAgent**: Routes inputs to appropriate processing agents based on source application type
- **ConsultWriterNode**: Generates formal consultation reports from clinical-narrative application inputs
- **Survey7WriterNode**: Creates medical summaries from survey-patient application screening results
- **FullIntakeWriterNode**: Produces comprehensive medical records from survey-frontend application assessments
- **OtherInputHandlerAgent**: Manages error handling and unexpected input scenarios

### 5. MongoDB Document Database

A centralized data storage system that maintains:

- Patient assessment results and screening data
- Screener professional credentials and access permissions
- Medical record templates and report structures
- AI processing logs and quality control metrics
- Research data with pseudonymized patient identifiers for longitudinal studies

## Desired System Improvements

Based on the current system design and development status, the following improvements are recommended to enhance quality, completeness, and user experience:

### Data Security and Compliance

- **LGPD Compliance Framework**: Implement end-to-end encryption for MongoDB data storage, pseudonymization of patient identifiers, and audit trails for data access
- **Access Control Enhancement**: Develop granular role-based permissions with multi-factor authentication for professional screeners
- **Data Retention Policies**: Establish automated data lifecycle management with configurable retention periods aligned with healthcare regulations

### Clinical Safety and Quality Assurance

- **Automated Validation Pipeline**: Implement real-time fact-checking mechanisms against medical knowledge bases to reduce AI hallucination risks in clinical documentation
- **Human-in-the-Loop Workflow**: Create mandatory professional review steps for all AI-generated reports before finalization, with version control tracking
- **Emergency Protocol Integration**: Develop automated alert systems for critical findings that require immediate professional attention, despite NDD focus

### User Experience and Accessibility

- **Voice Interaction Support**: Implement text-to-speech and speech-to-text capabilities for users with motor impairments or reading difficulties
- **Adaptive Questionnaire Interface**: Develop age-appropriate presentation modes for questionnaires, particularly for pediatric populations
- **Offline Mode Capability**: Create limited offline functionality for questionnaire completion with secure synchronization when connectivity resumes

### Professional Workflow Integration

- **Cross-Application Data Sharing**: Implement secure patient data portability between applications with consent management systems
- **Longitudinal Analytics Dashboard**: Develop visual progress tracking tools for screeners to monitor patient symptom evolution over time
- **Research-Practice Bridge**: Create automated anonymized data export features for contributing to normative database development while maintaining patient privacy

### Scalability and Performance

- **Load Balancing Architecture**: Implement containerized microservices with auto-scaling capabilities to handle variable user loads
- **Caching Strategy**: Develop intelligent caching mechanisms for frequently accessed questionnaire templates and report structures
- **Performance Monitoring**: Integrate real-time system health monitoring with alerts for resource utilization thresholds

### Quality Control and Research Support

- **Continuous Validation Framework**: Implement automated A/B testing of AI-generated reports against human expert evaluations
- **Multilingual Expansion Support**: Design modular prompt architecture to facilitate future adaptation to different linguistic and cultural contexts
- **Research Collaboration Portal**: Create secure data sharing interfaces for authorized researchers working on visual hypersensitivity validation studies
