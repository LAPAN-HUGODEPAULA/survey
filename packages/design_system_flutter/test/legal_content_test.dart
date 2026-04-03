import 'dart:io';

import 'package:design_system_flutter/components/legal/legal_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('packaged legal assets stay in sync with source documents', () {
    final repoRoot = Directory.current.parent.parent.path;
    final noticeSource = File(
      '$repoRoot/docs/legal/Aviso-Inicial-de-Uso-ptbr.md',
    );
    final noticeAsset = File(
      '$repoRoot/packages/design_system_flutter/assets/legal/Aviso-Inicial-de-Uso-ptbr.md',
    );
    final termsSource = File(
      '$repoRoot/docs/legal/Termo-de-Uso-e-Política-de-Privacidade-ptbr.md',
    );
    final termsAsset = File(
      '$repoRoot/packages/design_system_flutter/assets/legal/Termo-de-Uso-e-Política-de-Privacidade-ptbr.md',
    );

    expect(noticeAsset.readAsStringSync(), noticeSource.readAsStringSync());
    expect(termsAsset.readAsStringSync(), termsSource.readAsStringSync());
  });

  test('initial notice parser extracts the checkbox label from legal markdown',
      () {
    final repoRoot = Directory.current.parent.parent.path;
    final noticeMarkdown = File(
      '$repoRoot/packages/design_system_flutter/assets/legal/Aviso-Inicial-de-Uso-ptbr.md',
    ).readAsStringSync();

    final document =
        DsLegalContentRepository.parseInitialNotice(noticeMarkdown);

    expect(document.type, DsLegalDocumentType.initialNotice);
    expect(
      document.markdown,
      isNot(contains('**Checkbox sugerido**')),
    );
    expect(
      document.checkboxLabel,
      'Li e concordo com o Termo de Uso e Política de Privacidade e estou ciente de que o fornecimento dos meus dados é voluntário, nos termos informados.',
    );
  });
}
