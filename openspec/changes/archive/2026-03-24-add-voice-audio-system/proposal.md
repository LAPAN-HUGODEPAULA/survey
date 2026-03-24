# Change: Voice and Audio System for Clinical Narrative

## Why
The `clinical-narrative` app needs voice capture with reliable transcription to reduce typing time and improve clinical record quality. This proposal formalizes a hybrid approach (browser preview + final server processing) with a modular, configurable architecture that keeps the STT provider decoupled.

## What Changes
- Define separate capabilities for voice capture, transcription preview, final processing, playback, and audio retention.
- Specify a provider-agnostic transcription contract (Strategy/Adapter) with configurable settings.
- Detail UX requirements, microphone permissions, error states, and text fallback.
- Establish an audio retention and deletion policy aligned with LGPD.

## Impact
- Affected specs: `voice-capture`, `transcription-preview`, `transcription-processing`, `audio-playback`, `audio-retention`, `error-handling`.
- Affected code: `apps/clinical-narrative/`, `services/clinical-writer-api/`, `packages/contracts/`, `packages/design_system_flutter/`.
- Related to: `add-clinical-narrative-overview` (capability `process-voice-audio`).
