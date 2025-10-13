import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../user_management/data/services/user_management_service.dart';
import '../../../user_management/domain/models/extended_user_model.dart';

class HRApplicantsPage extends StatefulWidget {
  const HRApplicantsPage({super.key});

  @override
  State<HRApplicantsPage> createState() => _HRApplicantsPageState();
}

class _HRApplicantsPageState extends State<HRApplicantsPage> {
  List<ExtendedUserModel> _applicants = [];
  List<ExtendedUserModel> _filteredApplicants = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadApplicants();
  }

  Future<void> _loadApplicants() async {
    setState(() => _isLoading = true);
    
    try {
      final allUsers = await UserManagementService.getAllUsers();
      final applicants = allUsers.where((user) => user.role.name == 'applicant').toList();
      
      setState(() {
        _applicants = applicants;
        _filteredApplicants = applicants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading applicants: $e')),
        );
      }
    }
  }

  void _filterApplicants() {
    setState(() {
      _filteredApplicants = _applicants.where((applicant) {
        final matchesSearch = _searchQuery.isEmpty ||
            applicant.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            applicant.email.toLowerCase().contains(_searchQuery.toLowerCase());
        
        return matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return AppHeader(
                  title: 'Applicant Management',
                  subtitle: 'Manage and review applicant profiles',
                  user: authProvider.user,
                  showBackButton: true,
                );
              },
            ),

            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search applicants...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  _searchQuery = value;
                  _filterApplicants();
                },
              ),
            ),

            // Statistics
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.backgroundLight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard('Total Applicants', _applicants.length.toString(), Icons.people),
                  _buildStatCard('Active', _applicants.where((a) => a.isActive).length.toString(), Icons.check_circle),
                  _buildStatCard('Verified', _applicants.where((a) => a.isEmailVerified).length.toString(), Icons.verified),
                ],
              ),
            ),

            // Applicants List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredApplicants.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No applicants found',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _applicants.isEmpty 
                                    ? 'No applicants have registered yet'
                                    : 'Try adjusting your search criteria',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadApplicants,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredApplicants.length,
                            itemBuilder: (context, index) {
                              final applicant = _filteredApplicants[index];
                              return _buildApplicantCard(applicant);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantCard(ExtendedUserModel applicant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showApplicantDetails(applicant),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      applicant.fullName.isEmpty 
                          ? '?' 
                          : applicant.fullName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          applicant.fullName.isEmpty ? 'Unnamed User' : applicant.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          applicant.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      if (applicant.isEmailVerified)
                        const Icon(
                          Icons.verified,
                          color: Colors.green,
                          size: 20,
                        ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: applicant.isActive ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          applicant.isActive ? 'Active' : 'Inactive',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Joined ${_formatDate(applicant.createdAt)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Last login: ${applicant.lastLoginAt != null ? _formatDate(applicant.lastLoginAt!) : "Never"}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/applications', extra: applicant),
                      icon: const Icon(Icons.work, size: 16),
                      label: const Text('Applications'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showApplicantDetails(applicant),
                      icon: const Icon(Icons.person, size: 16),
                      label: const Text('View Profile'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'today';
    } else if (difference == 1) {
      return 'yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showApplicantDetails(ExtendedUserModel applicant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        applicant.fullName.isEmpty 
                            ? '?' 
                            : applicant.fullName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            applicant.fullName.isEmpty ? 'Unnamed User' : applicant.fullName,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            applicant.email,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailSection('Account Information', [
                          'Role: ${applicant.role.name}',
                          'Status: ${applicant.isActive ? "Active" : "Inactive"}',
                          'Email Verified: ${applicant.isEmailVerified ? "Yes" : "No"}',
                          'Account Created: ${applicant.createdAt.toString().split(' ')[0]}',
                          'Last Login: ${applicant.lastLoginAt?.toString().split(' ')[0] ?? "Never"}',
                        ]),
                        
                        const SizedBox(height: 24),
                        
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.push('/applications', extra: applicant);
                                },
                                child: const Text('View Applications'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // TODO: Implement disable/enable user functionality
                                },
                                child: Text(applicant.isActive ? 'Disable' : 'Enable'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(String title, List<String> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...details.map((detail) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(detail),
        )),
      ],
    );
  }
}