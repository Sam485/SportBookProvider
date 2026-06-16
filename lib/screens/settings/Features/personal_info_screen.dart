import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text('Edit Profile', style: AppTheme.tsTitleAdaptive(context)),
        actionsPadding: EdgeInsets.all(10),
        actions: [
          InkWell(
            onTap: () {},
            child: Text('Save', style: AppTheme.tsAccent),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(child: _buildImageHolder()),
            SliverToBoxAdapter(child: _buildTextField()),
            SliverToBoxAdapter(child: _buildSaveButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHolder() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Center(
        child: Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.kCardAlt,
                border: Border.all(color: AppTheme.kAccent),
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 75,
                  color: AppTheme.kLightCardAlt,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.kAccent,
                ),
                padding: EdgeInsets.all(5),
                child: Icon(Icons.camera_alt),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Form(
        child: Column(
          children: [
            TextFormField(
              decoration: AppTheme.textFieldDecoration(
                Icons.person,
                'Full Name',
              ).copyWith(label: Text('Full Name')),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: AppTheme.textFieldDecoration(
                Icons.email,
                'Enter your email',
              ).copyWith(label: Text('Email')),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: AppTheme.textFieldDecoration(
                Icons.location_pin,
                'Enter your location',
              ).copyWith(label: Text('Location')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {},
          style: AppTheme.elevatedButtonStyle(),
          child: Text('Save Changes'),
        ),
      ),
    );
  }
}
