// import 'package:finpal/presentation/bloc/expense/expense_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../../../bloc/expense/expense_bloc.dart';

// class ExpenseCategoryChart extends StatelessWidget {
//   const ExpenseCategoryChart({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ExpenseBloc, ExpenseState>(
//       builder: (context, state) {
//         if (state is! ExpenseLoaded) {
//           return const SizedBox(
//             height: 180,
//             child: Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (state.categoryTotals.isEmpty) {
//           return const SizedBox(
//             height: 180,
//             child: Center(
//               child: Text('아직 지출 내역이 없습니다.'),
//             ),
//           );
//         }

//         return Card(
//           elevation: 0,
//           color: Theme.of(context).colorScheme.surface,
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '카테고리별 지출',
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     // 원형 차트
//                     SizedBox(
//                       height: 140,
//                       width: 140,
//                       child: PieChart(
//                         PieChartData(
//                           sectionsSpace: 2,
//                           centerSpaceRadius: 35,
//                           sections:
//                               _createPieChartSections(state.categoryTotals),
//                           borderData: FlBorderData(show: false),
//                         ),
//                         swapAnimationDuration:
//                             const Duration(milliseconds: 500),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     // 범례
//                     Expanded(
//                       child: _buildLegend(
//                         state.categoryTotals,
//                         state.totalAmount,
//                         context,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   List<PieChartSectionData> _createPieChartSections(
//       Map<String, double> categoryTotals) {
//     final total =
//         categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
//     final colors = [
//       const Color(0xFF5C6BC0), // Indigo
//       Colors.red,
//       Colors.green,
//       Colors.yellow,
//       Colors.purple,
//       Colors.orange,
//       Colors.teal,
//       Colors.pink,
//     ];

//     return categoryTotals.entries.toList().asMap().entries.map((entry) {
//       final index = entry.key;
//       final amount = entry.value.value;
//       final percentage = (amount / total * 100);

//       return PieChartSectionData(
//         color: colors[index % colors.length],
//         value: amount,
//         title: '${percentage.toStringAsFixed(1)}%',
//         radius: 100,
//         titleStyle: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//         ),
//       );
//     }).toList();
//   }

//   Widget _buildLegend(Map<String, double> categoryTotals, double totalAmount,
//       BuildContext context) {
//     final colors = [
//       const Color(0xFF5C6BC0), // Indigo
//       Colors.red,
//       Colors.green,
//       Colors.yellow,
//       Colors.purple,
//       Colors.orange,
//       Colors.teal,
//       Colors.pink,
//     ];

//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: categoryTotals.entries.toList().asMap().entries.map((entry) {
//         final index = entry.key;
//         final category = entry.value.key;
//         final amount = entry.value.value;

//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 4.0),
//           child: Row(
//             children: [
//               Container(
//                 width: 12,
//                 height: 12,
//                 decoration: BoxDecoration(
//                   color: colors[index % colors.length],
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   category,
//                   style: const TextStyle(fontSize: 12),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               Text(
//                 '${amount.toStringAsFixed(0)}원',
//                 style: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
