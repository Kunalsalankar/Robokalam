import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../../models/portfolio.dart';
import 'dart:ui';

class PortfolioScreen extends StatefulWidget {
  @override
  _PortfolioScreenState createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _skill1Controller = TextEditingController();
  final TextEditingController _skill2Controller = TextEditingController();
  final TextEditingController _skill3Controller = TextEditingController();
  final TextEditingController _projectTitleController = TextEditingController();
  final TextEditingController _projectDescController = TextEditingController();

  Portfolio? _userPortfolio;
  bool _isLoading = true;
  bool _isEditing = false;

  // Animation controller for tab switching
  late TabController _tabController;

  // Define our color scheme
  final Color primaryColor = Color(0xFF3F51B5); // Indigo
  final Color accentColor = Color(0xFF4CAF50); // Green
  final Color backgroundColor = Color(0xFFF5F7FA); // Light grayish blue
  final Color cardColor = Colors.white;
  final Color textColor = Color(0xFF2C3E50); // Dark blue/gray
  final Color lightTextColor = Color(0xFF7F8C8D); // Grayish
  final Color errorColor = Color(0xFFE74C3C); // Red

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPortfolio();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _collegeController.dispose();
    _skill1Controller.dispose();
    _skill2Controller.dispose();
    _skill3Controller.dispose();
    _projectTitleController.dispose();
    _projectDescController.dispose();
    super.dispose();
  }

  Future<void> _loadPortfolio() async {
    setState(() => _isLoading = true);

    try {
      final portfolio = await DatabaseHelper.instance.getPortfolio();

      if (portfolio != null) {
        setState(() {
          _userPortfolio = portfolio;
          _nameController.text = portfolio.name;
          _collegeController.text = portfolio.college;

          List<String> skills = portfolio.skills.split(',');
          _skill1Controller.text = skills.length > 0 ? skills[0] : '';
          _skill2Controller.text = skills.length > 1 ? skills[1] : '';
          _skill3Controller.text = skills.length > 2 ? skills[2] : '';

          _projectTitleController.text = portfolio.projectTitle;
          _projectDescController.text = portfolio.projectDescription;

          // If portfolio exists, show the view tab first
          if (!_isEditing) {
            _tabController.animateTo(0);
          }
        });
      } else {
        // If no portfolio, show the edit tab first
        _tabController.animateTo(1);
        setState(() => _isEditing = true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading portfolio: $e'),
          backgroundColor: errorColor,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePortfolio() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final skills = [
          _skill1Controller.text.trim(),
          _skill2Controller.text.trim(),
          _skill3Controller.text.trim(),
        ].where((skill) => skill.isNotEmpty).join(',');

        final portfolio = Portfolio(
          id: _userPortfolio?.id ?? 1,
          name: _nameController.text,
          college: _collegeController.text,
          skills: skills,
          projectTitle: _projectTitleController.text,
          projectDescription: _projectDescController.text,
        );

        if (_userPortfolio == null) {
          await DatabaseHelper.instance.insertPortfolio(portfolio);
        } else {
          await DatabaseHelper.instance.updatePortfolio(portfolio);
        }

        setState(() {
          _userPortfolio = portfolio;
          _isEditing = false;
          _tabController.animateTo(0); // Switch to view tab after saving
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Portfolio saved successfully!'),
            backgroundColor: accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving portfolio: $e'),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startEditing() {
    setState(() => _isEditing = true);
    _tabController.animateTo(1); // Switch to edit tab
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: accentColor,
          error: errorColor,
        ),
        scaffoldBackgroundColor: backgroundColor,
        cardColor: cardColor,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: textColor),
          bodyMedium: TextStyle(color: textColor),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: cardColor,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: errorColor),
          ),
          labelStyle: TextStyle(color: lightTextColor),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
      ),
      child: Scaffold(
        body: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        )
            : NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 240.0,
                floating: false,
                pinned: true,
                backgroundColor: primaryColor,
                elevation: 8,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Professional Portfolio',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  titlePadding: EdgeInsets.only(left: 16, bottom: 56),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
                        fit: BoxFit.cover,
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              primaryColor.withOpacity(0.3),
                              primaryColor.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                      // Bottom blur overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                            child: Container(
                              height: 80,
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.visibility, size: 22),
                      text: 'PREVIEW',
                    ),
                    Tab(
                      icon: Icon(Icons.edit_note, size: 22),
                      text: 'EDIT',
                    ),
                  ],
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: accentColor,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontSize: 14,
                  ),
                ),
              ),
            ];
          },
          body: Container(
            color: backgroundColor,
            child: TabBarView(
              controller: _tabController,
              children: [
                // View Portfolio Tab
                _userPortfolio == null
                    ? EmptyPortfolioView(onCreatePressed: _startEditing)
                    : PortfolioView(
                  portfolio: _userPortfolio!,
                  onEdit: _startEditing,
                  primaryColor: primaryColor,
                  accentColor: accentColor,
                ),

                // Edit Portfolio Tab
                SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Personal Information', Icons.person_outline),
                        SizedBox(height: 16),
                        _buildInputField(
                          controller: _nameController,
                          label: 'Full Name',
                          icon: Icons.badge_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _buildInputField(
                          controller: _collegeController,
                          label: 'College/University',
                          icon: Icons.school_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your college name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 32),
                        _buildSectionHeader('Technical Skills', Icons.engineering_outlined),
                        SizedBox(height: 16),
                        _buildInputField(
                          controller: _skill1Controller,
                          label: 'Primary Skill',
                          icon: Icons.psychology_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter at least one skill';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12),
                        _buildInputField(
                          controller: _skill2Controller,
                          label: 'Secondary Skill',
                          icon: Icons.lightbulb_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a second skill';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12),
                        _buildInputField(
                          controller: _skill3Controller,
                          label: 'Additional Skill',
                          icon: Icons.category_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a third skill';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 32),
                        _buildSectionHeader('Featured Project', Icons.work_outline),
                        SizedBox(height: 16),
                        _buildInputField(
                          controller: _projectTitleController,
                          label: 'Project Title',
                          icon: Icons.title,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a project title';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _buildInputField(
                          controller: _projectDescController,
                          label: 'Project Description',
                          icon: Icons.description_outlined,
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a project description';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _savePortfolio,
                            icon: Icon(Icons.save_outlined, size: 20),
                            label: Text(
                              'SAVE PORTFOLIO',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 22,
            ),
          ),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    int maxLines = 1,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryColor.withOpacity(0.7), size: 22),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 16 : 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        maxLines: maxLines,
        validator: validator,
        style: TextStyle(
          fontSize: 16,
          color: textColor,
        ),
      ),
    );
  }
}

class EmptyPortfolioView extends StatelessWidget {
  final VoidCallback onCreatePressed;

  const EmptyPortfolioView({Key? key, required this.onCreatePressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 70,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Portfolio Created Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Create your professional portfolio to showcase your skills and projects',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onCreatePressed,
            icon: Icon(Icons.add),
            label: Text(
              'CREATE PORTFOLIO',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PortfolioView extends StatelessWidget {
  final Portfolio portfolio;
  final VoidCallback onEdit;
  final Color primaryColor;
  final Color accentColor;

  const PortfolioView({
    Key? key,
    required this.portfolio,
    required this.onEdit,
    required this.primaryColor,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final skills = portfolio.skills.split(',');

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Card
          Card(
            elevation: 4,
            shadowColor: primaryColor.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.white, primaryColor.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [primaryColor, accentColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: Text(
                        portfolio.name.isNotEmpty
                            ? portfolio.name[0].toUpperCase()
                            : "P",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    portfolio.name,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.school_outlined, size: 18, color: primaryColor),
                        SizedBox(width: 8),
                        Text(
                          portfolio.college,
                          style: TextStyle(
                            fontSize: 16,
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),

          // Skills Section
          _buildSectionTitle('Technical Expertise', Icons.psychology_outlined),
          SizedBox(height: 16),
          Row(
            children: List.generate(skills.length, (index) {
              return Expanded(
                child: Card(
                  elevation: 4,
                  shadowColor: primaryColor.withOpacity(0.2),
                  margin: EdgeInsets.symmetric(horizontal: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          index == 0 ? primaryColor : (index == 1 ? accentColor : Color(0xFF5C6BC0)),
                          index == 0 ? primaryColor.withOpacity(0.8) : (index == 1 ? accentColor.withOpacity(0.8) : Color(0xFF5C6BC0).withOpacity(0.8)),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            index == 0 ? Icons.psychology_outlined : (index == 1 ? Icons.lightbulb_outline : Icons.category_outlined),
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          skills[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 30),

          // Project Section
          _buildSectionTitle('Featured Project', Icons.work_outline),
          SizedBox(height: 16),
          Card(
            elevation: 4,
            shadowColor: primaryColor.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.rocket_launch_outlined,
                          color: accentColor,
                          size: 26,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          portfolio.projectTitle,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8, right: 8, top: 16),
                    child: Divider(
                      color: Colors.grey.withOpacity(0.3),
                      thickness: 1,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    portfolio.projectDescription,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Color(0xFF34495E),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 40),

          // Edit Button
          Center(
            child: ElevatedButton.icon(
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined),
              label: Text(
                'EDIT PORTFOLIO',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
                shadowColor: accentColor.withOpacity(0.4),
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Container(
      margin: EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 22,
            ),
          ),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}