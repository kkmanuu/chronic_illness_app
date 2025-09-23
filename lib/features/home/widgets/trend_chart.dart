import 'package:chronic_illness_app/core/models/reading_model.dart';
import 'package:chronic_illness_app/core/providers/auth_provider.dart';
import 'package:chronic_illness_app/core/providers/reading_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrendChart extends StatelessWidget {
  const TrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return StreamBuilder<List<ReadingModel>>(
      stream: Provider.of<ReadingProvider>(context).getReadingsStream(authProvider.user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading trends'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        }
        final readings = snapshot.data!;
        return LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: readings.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.bloodSugar)).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}