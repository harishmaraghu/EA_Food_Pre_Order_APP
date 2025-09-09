import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../data/models/role_model.dart';
import 'ProductListScreen.dart';


class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  String? selectedRole;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;





  final List<RoleModel> roles = [
    RoleModel(
      name: "Customer",
      description: "Individual customer purchasing for personal/family use",
      businessRole: "End Consumer",
      icon: Icons.person_outline,
      color: AppColors.customerColor,
      capabilities: [
        "Browse product catalog",
        "Place small quantity orders",
        "Select delivery time slots",
        "Track order status"
      ],
      orderExamples: ["2L milk", "1 bread packet", "5kg rice", "1L oil"],
      orderType: "Small Orders",
      businessImpact: "Individual demand that flows into consolidated planning",
    ),
    RoleModel(
      name: "TSU",
      description: "Territory Sales User covering multiple customers/shops",
      businessRole: "Territory Sales User",
      icon: Icons.store_outlined,
      color: AppColors.tsuColor,
      capabilities: [
        "Collect area-wide demand",
        "Place medium-bulk orders",
        "Manage territory customers",
        "Consolidate local orders"
      ],
      orderExamples: ["50L milk", "20 bread packets", "100kg rice", "25L oil"],
      orderType: "Medium-Bulk Orders",
      businessImpact: "Area-level consolidation for efficient distribution",
    ),
    RoleModel(
      name: "SR",
      description: "Sales Representative managing multiple territories/TSUs",
      businessRole: "Sales Representative",
      icon: Icons.business_center_outlined,
      color: AppColors.srColor,
      capabilities: [
        "Multi-territory management",
        "Place very bulk orders",
        "Strategic planning & analytics",
        "Higher-level consolidation"
      ],
      orderExamples: ["500L milk", "200 bread packets", "1000kg rice", "100L oil"],
      orderType: "Very Bulk Orders",
      businessImpact: "Territory-wise consolidation for supply chain optimization",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Select Your Business Role",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Container(
        decoration:  BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      selectedRole != null
                          ? "Welcome, $selectedRole!"
                          : "Choose Your Business Role",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedRole != null
                          ? _getSelectedRoleSubtitle()
                          : "Select your role in the supply chain",
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Role Cards
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: roles.length,
                  itemBuilder: (context, index) {
                    final role = roles[index];
                    final isSelected = selectedRole == role.name;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => _selectRole(context, role),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? role.color.withOpacity(0.1) : AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? role.color : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: isSelected ? 12 : 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Role Header
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: role.color.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        role.icon,
                                        color: role.color,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                role.name,
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected ? role.color : AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: role.color.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  role.orderType,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: role.color,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            role.businessRole,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: role.color,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            role.description,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AnimatedRotation(
                                      turns: isSelected ? 0.5 : 0,
                                      duration: const Duration(milliseconds: 300),
                                      child: Icon(
                                        isSelected ? Icons.expand_less : Icons.expand_more,
                                        color: isSelected ? role.color : AppColors.textLight,
                                        size: 28,
                                      ),
                                    ),
                                  ],
                                ),

                                if (isSelected) ...[
                                  const SizedBox(height: 20),

                                  // Business Impact
                                  _buildDetailSection(
                                    "Business Impact",
                                    role.businessImpact,
                                    Icons.trending_up,
                                    role.color,
                                  ),

                                  const SizedBox(height: 16),

                                  // Order Examples
                                  _buildDetailSection(
                                    "Typical Order Quantities",
                                    null,
                                    Icons.shopping_cart,
                                    role.color,
                                    items: role.orderExamples,
                                  ),

                                  const SizedBox(height: 16),

                                  // Capabilities
                                  _buildDetailSection(
                                    "Your Capabilities",
                                    null,
                                    Icons.check_circle_outline,
                                    role.color,
                                    items: role.capabilities,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Continue Button
              if (selectedRole != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => _continueWithRole(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getSelectedRoleColor(),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.login),
                              const SizedBox(width: 8),
                              const Text(
                                "Continue as ",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                selectedRole!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Access product list with ${_getOrderTypeText()} capabilities",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(
      String title,
      String? description,
      IconData icon,
      Color color, {
        List<String>? items,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (description != null)
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        if (items != null) ...[
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: items.map((item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }

  String _getSelectedRoleSubtitle() {
    final role = roles.firstWhere((r) => r.name == selectedRole);
    return "Ready to access ${role.orderType.toLowerCase()} interface";
  }

  Color _getSelectedRoleColor() {
    final role = roles.firstWhere((r) => r.name == selectedRole);
    return role.color;
  }

  String _getOrderTypeText() {
    final role = roles.firstWhere((r) => r.name == selectedRole);
    return role.orderType.toLowerCase();
  }

  void _selectRole(BuildContext context, RoleModel role) {
    setState(() {
      selectedRole = selectedRole == role.name ? null : role.name;
    });


  }

  void _continueWithRole(BuildContext context) {
    if (selectedRole != null) {
      final role = roles.firstWhere((r) => r.name == selectedRole);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: role.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  role.icon,
                  color: role.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Confirm Role Selection",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      role.orderType,
                      style: TextStyle(
                        fontSize: 12,
                        color: role.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Continue as ${role.name}?",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                "You'll access the product catalog with ${role.orderType.toLowerCase()} capabilities.",
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: role.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: role.color, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Orders will be saved with userType = ${role.name}",
                        style: TextStyle(
                          fontSize: 12,
                          color: role.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductListScreen(userType: selectedRole!),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: role.color,
                foregroundColor: Colors.white,
              ),
              child: const Text("Continue"),
            ),
          ],
        ),
      );
    }
  }
}



