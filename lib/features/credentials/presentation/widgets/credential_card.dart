import 'package:flutter/material.dart';
import 'package:waternode/features/credentials/domain/models/account_credential.dart';

class CredentialCard extends StatelessWidget {
  const CredentialCard({super.key, required this.credential});

  final AccountCredential credential;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(credential.mobile),
        subtitle: Text('积分 ${credential.points}'),
        trailing: Text(
          credential.isValid ? '有效' : '失效',
          style: TextStyle(
            color: credential.isValid
                ? Colors.green.shade700
                : Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}
