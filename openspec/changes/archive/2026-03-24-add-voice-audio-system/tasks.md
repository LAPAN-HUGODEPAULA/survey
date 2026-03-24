## 1. Specification
- [x] 1.1 Validate that new capabilities do not duplicate existing requirements in `openspec/specs`
- [x] 1.2 Refine scenarios for capture, preview, processing, playback, retention, and errors

## 2. Contracts and Integrations
- [x] 2.1 Update backend OpenAPI with a provider-agnostic transcription endpoint
- [x] 2.2 Update generated SDKs in `packages/contracts/generated/dart/`

## 3. Frontend (clinical-narrative)
- [x] 3.1 Implement audio capture service with configurable settings
- [x] 3.2 Implement real-time preview with fallback when Web Speech API is unavailable
- [x] 3.3 Implement playback UX and error states

## 4. Backend (clinical-writer-api)
- [x] 4.1 Implement transcription interface (Strategy/Adapter) and configurable providers
- [x] 4.2 Implement processing pipeline with metadata and quality validation
- [x] 4.3 Implement audio retention policy and deletion audit

## 5. Quality and Validation
- [x] 5.1 Unit tests for transcription service and payload validation
- [x] 5.2 Integration tests for upload -> transcription -> response flow
- [x] 5.3 Run `python -m compileall services/clinical-writer-api/` and `flutter analyze` in `apps/clinical-narrative/`
