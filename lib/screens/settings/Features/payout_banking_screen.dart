import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme.dart';
import 'package:flutter_application_1/translations/app_translations.dart';

class PayoutBankingScreen extends StatefulWidget {
  const PayoutBankingScreen({super.key});

  @override
  State<PayoutBankingScreen> createState() => _PayoutBankingScreenState();
}

class _PayoutBankingScreenState extends State<PayoutBankingScreen> {
  List<AccountData> accounts = [
    AccountData(
      intial: 'ABA',
      title: 'ABA Bank',
      accountNumber: 'Saving *****4521',
      isDefault: true,
      color: Colors.blue,
    ),
    AccountData(
      intial: 'Wing',
      title: 'Wing Money',
      accountNumber: '+855 12 345 678',
      isDefault: false,
      color: Colors.green,
    ),
  ];

  List<TransactionData> transactions = [
    TransactionData(
      icon: Icons.attach_money_outlined,
      title: 'Booking payment',
      dateName: 'Jun 11 Sophea Rith',
      amount: '+\$10.80',
      status: 'Settled',
      color: Colors.green,
    ),
    TransactionData(
      icon: Icons.money_off_csred_outlined,
      title: 'Withdrawal to ABA',
      dateName: 'Jun 8 *****4521',
      amount: '-\$200.00',
      status: 'Settled',
      color: Colors.red,
    ),
    TransactionData(
      icon: Icons.attach_money_outlined,
      title: 'Booking Payment',
      dateName: 'Jun 11 Dara Vuth',
      amount: '+\$31.50',
      status: 'Pending',
      color: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : AppTheme.kLightText,
          ),
        ),
        title: Text(
          'payout_and_banking'.tr(context),
          style: AppTheme.tsTitleAdaptive(context),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(child: _buildTotalBalanceSection()),
            SliverToBoxAdapter(child: _buildLinkedAccountsSection()),
            SliverToBoxAdapter(child: _buildRecentTransaction()),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBalanceSection() {

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: AppTheme.cardDecorationAdaptive(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'available_balance'.tr(context),
                  style: AppTheme.tsBodyAdaptive(context),
                ),
                Text(
                  '\$ 348.60',
                  style: AppTheme.tsLabelAdaptive(
                    context,
                  ).copyWith(fontFamily: AppTheme.fontFamily, fontSize: 28),
                ),
                Text(
                  'next_payout'
                      .tr(context)
                      .replaceAll('{date}', 'Jun 15, 2026'),
                  style: AppTheme.tsBodyAdaptive(context),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 45,
                  width: 180,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: AppTheme.elevatedButtonStyle().copyWith(
                      textStyle: const WidgetStatePropertyAll(
                        TextStyle(fontFamily: AppTheme.fontFamily),
                      ),
                    ),
                    child: Text(
                      'withdraw_now'.tr(context),
                      style: const TextStyle(fontFamily: AppTheme.fontFamily),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: AppTheme.cardDecorationAdaptive(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'this_month'.tr(context),
                          style: AppTheme.tsBodyAdaptive(context),
                        ),
                        Text(
                          '\$1,240',
                          style: AppTheme.tsTitleAdaptive(context).copyWith(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          '+18%',
                          style: AppTheme.tsBodyAdaptive(context).copyWith(
                            fontFamily: AppTheme.fontFamily,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: AppTheme.cardDecorationAdaptive(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'total_earned'.tr(context),
                          style: AppTheme.tsBodyAdaptive(context),
                        ),
                        Text(
                          '\$12,480',
                          style: AppTheme.tsTitleAdaptive(context).copyWith(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          'since_date'
                              .tr(context)
                              .replaceAll('{date}', 'Jan 2026'),
                          style: AppTheme.tsBodyAdaptive(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedAccountsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'linked_accounts'.tr(context),
            style: AppTheme.tsLabelAdaptive(context),
          ),
          const SizedBox(height: 10),
          ...List.generate(
            accounts.length,
            (index) => _buildBankCard(accounts[index]),
          ),
          SizedBox(
            height: 50,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(fontFamily: AppTheme.fontFamily),
              ),
              child: Text(
                'add_bank_account'.tr(context),
                style: const TextStyle(fontFamily: AppTheme.fontFamily),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard(AccountData data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: AppTheme.cardDecorationAdaptive(context),
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: data.color.withValues(alpha: 0.4),
            ),
            child: Center(
              child: Text(
                data.intial,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.kLightText,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.title, style: AppTheme.tsLabelAdaptive(context)),
              Text(data.accountNumber, style: AppTheme.tsBodyAdaptive(context)),
              if (data.isDefault) _buildBadge(),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit),
            color: Colors.amber,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransaction() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'recent_transactions'.tr(context),
            style: AppTheme.tsLabelAdaptive(context),
          ),
          const SizedBox(height: 10),
          ...List.generate(
            transactions.length,
            (index) => _buildTransaction(transactions[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'default_account'.tr(context),
        style: AppTheme.tsBodyAdaptive(
          context,
        ).copyWith(fontFamily: AppTheme.fontFamily, color: Colors.green),
      ),
    );
  }

  Widget _buildTransaction(TransactionData data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Icon(data.icon, color: data.color)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: AppTheme.tsLabelAdaptive(
                    context,
                  ).copyWith(fontSize: 14),
                ),
                Text(data.dateName, style: AppTheme.tsBodyAdaptive(context)),
              ],
            ),
            const Spacer(),
            Column(
              children: [
                Text(
                  data.amount,
                  style: AppTheme.tsAccent.copyWith(
                    fontFamily: AppTheme.fontFamily,
                    color: data.color,
                  ),
                ),
                Text(
                  data.status == 'Settled'
                      ? 'settled'.tr(context)
                      : 'pending'.tr(context),
                  style: AppTheme.tsSubAdaptive(context),
                ),
              ],
            ),
          ],
        ),
        if (data != transactions.last)
          SizedBox(
            width: double.infinity,
            child: Divider(
              color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
              thickness: 0.5,
            ),
          ),
      ],
    );
  }
}

class AccountData {
  final String intial;
  final String title;
  final String accountNumber;
  final bool isDefault;
  final Color color;
  AccountData({
    required this.intial,
    required this.title,
    required this.accountNumber,
    required this.isDefault,
    required this.color,
  });
}

class TransactionData {
  final IconData icon;
  final String title;
  final String dateName;
  final String amount;
  final String status;
  final Color color;
  TransactionData({
    required this.icon,
    required this.title,
    required this.dateName,
    required this.amount,
    required this.status,
    required this.color,
  });
}
