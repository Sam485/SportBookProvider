import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme.dart';

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
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios),
        ),
        title: Text('Payout & Banking', style: AppTheme.tsTitle),
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
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            decoration: AppTheme.cardDecorationAdaptive(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Available balance',
                  style: AppTheme.tsBodyAdaptive(context),
                ),
                Text(
                  '\$ 348.60',
                  style: AppTheme.tsLabelAdaptive(
                    context,
                  ).copyWith(fontSize: 28),
                ),
                Text(
                  'Next payout: Jun 15,2026',
                  style: AppTheme.tsBodyAdaptive(context),
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 45,
                  width: 180,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: AppTheme.elevatedButtonStyle(),
                    child: Text('Withdraw now'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: AppTheme.cardDecorationAdaptive(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('This month', style: AppTheme.tsBody),
                        Text(
                          '\$1,240',
                          style: AppTheme.tsLabel.copyWith(fontSize: 22),
                        ),
                        Text(
                          '+18%',
                          style: AppTheme.tsBody.copyWith(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: AppTheme.cardDecorationAdaptive(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total earned', style: AppTheme.tsBody),
                        Text(
                          '\$12,480',
                          style: AppTheme.tsLabel.copyWith(fontSize: 22),
                        ),
                        Text(
                          'Since Jan 2026',
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
    return Padding(
      padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Linked accounts', style: AppTheme.tsLabel),
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
              style: AppTheme.outlineButtonStyle(),
              child: Text('Add bank account or e-wallet'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard(AccountData data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: AppTheme.cardDecorationAdaptive(context),
      margin: EdgeInsets.only(bottom: 10),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: data.color.withOpacity(0.4),
            ),
            child: Center(child: Text(data.intial)),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.title, style: AppTheme.tsLabelAdaptive(context)),
              Text(data.accountNumber, style: AppTheme.tsBodyAdaptive(context)),
              if (data.isDefault) _buildBadge(),
            ],
          ),
          Spacer(),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.edit),
            color: Colors.amber,
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.delete),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransaction() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent transactions', style: AppTheme.tsLabelAdaptive(context)),
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
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Default',
        style: AppTheme.tsBody.copyWith(color: Colors.green),
      ),
    );
  }

  Widget _buildTransaction(TransactionData data) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: data.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Icon(data.icon, color: data.color)),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: AppTheme.tsLabelAdaptive(
                    context,
                  ).copyWith(fontSize: 14),
                ),
                Text(data.dateName, style: AppTheme.tsBody),
              ],
            ),
            Spacer(),
            Column(
              children: [
                Text(
                  data.amount,
                  style: AppTheme.tsAccent.copyWith(color: data.color),
                ),
                Text(data.status, style: AppTheme.tsSub),
              ],
            ),
          ],
        ),
        if (data != transactions.last)
          SizedBox(
            width: double.infinity,
            child: Divider(color: AppTheme.kTextSub, thickness: 0.3),
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
