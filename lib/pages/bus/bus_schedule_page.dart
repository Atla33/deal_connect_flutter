import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BusSchedule {
  final String time;
  final String route;

  BusSchedule({required this.time, required this.route});
}

final List<BusSchedule> natalEAJSchedules = [
  BusSchedule(time: "06:30", route: "RIOGRANDENSE"),
  BusSchedule(time: "07:10", route: "LAGOA SALGADA"),
  BusSchedule(time: "08:30", route: "RIOGRANDENSE"),
  BusSchedule(time: "11:20", route: "LAGOA SALGADA"),
  BusSchedule(time: "11:40", route: "RIOGRANDENSE"),
  BusSchedule(time: "16:50", route: "LAGOA SALGADA"),
  BusSchedule(time: "17:20", route: "RIOGRANDENSE"),
];

final List<BusSchedule> macaibaEAJSchedules = [
  BusSchedule(time: "06:30", route: "TRAMPOLIM"),
  BusSchedule(time: "07:00", route: "TRAMPOLIM"),
  BusSchedule(time: "07:15", route: "RIOGRANDENSE"),
  BusSchedule(time: "07:30", route: "TRAMPOLIM"),
  BusSchedule(time: "08:00", route: "TRAMPOLIM"),
  BusSchedule(time: "08:15", route: "LAGOA SALGADA"),
  BusSchedule(time: "08:40", route: "TRAMPOLIM"),
  BusSchedule(time: "09:15", route: "RIOGRANDENSE"),
  BusSchedule(time: "12:15", route: "LAGOA SALGADA"),
  BusSchedule(time: "12:30", route: "RIOGRANDENSE"),
  BusSchedule(time: "15:00", route: "TRAMPOLIM"),
  BusSchedule(time: "18:00", route: "LAGOA SALGADA"),
];

final List<BusSchedule> eajMacaibaSchedules = [
  BusSchedule(time: "06:40", route: "TRAMPOLIM"),
  BusSchedule(time: "07:10", route: "TRAMPOLIM"),
  BusSchedule(time: "10:15", route: "LAGOA SALGADA"),
  BusSchedule(time: "12:20", route: "RIOGRANDENSE"),
  BusSchedule(time: "13:50", route: "TRAMPOLIM (VILAR)"),
  BusSchedule(time: "15:15", route: "LAGOA SALGADA"),
  BusSchedule(time: "15:15", route: "TRAMPOLIM (VILAR)"),
  BusSchedule(time: "15:30", route: "RIOGRANDENSE"),
];

final List<BusSchedule> fuscaoSchedules = [
  BusSchedule(time: "06:50", route: "SAINDO DA IGREJA MATRIZ"),
  BusSchedule(time: "12:30", route: "SAINDO DA EAJ"),
  BusSchedule(time: "17:15", route: "SAINDO DA EAJ"),
];

class BusSchedulePage extends StatelessWidget {
  const BusSchedulePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Horário dos Ônibus',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF042474),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ScheduleCategory(
              title: "Natal - EAJ",
              schedules: natalEAJSchedules,
              color: Color(0xFF7A8CB4),
            ),
            ScheduleCategory(
              title: "Macaíba - EAJ",
              schedules: macaibaEAJSchedules,
              color: Color(0xFF6576A3),
            ),
            ScheduleCategory(
              title: "EAJ - Macaíba",
              schedules: eajMacaibaSchedules,
              color: Color(0xFF7484B4),
            ),
            ScheduleCategory(
              title: "Fuscão",
              schedules: fuscaoSchedules,
              color: Color(0xFFB0BEC5),
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduleCategory extends StatelessWidget {
  final String title;
  final List<BusSchedule> schedules;
  final Color color;

  const ScheduleCategory({
    Key? key,
    required this.title,
    required this.schedules,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          backgroundColor: color,
          collapsedBackgroundColor: color,
          title: Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          children: schedules.expand((schedule) {
            final now = DateTime.now();
            final DateFormat dateFormat = DateFormat('HH:mm');
            final scheduleTime = dateFormat.parse(schedule.time);
            final isUpcoming = scheduleTime.isAfter(now);
            List<Widget> tiles = [
              Container(
                decoration: BoxDecoration(
                  color:
                      isUpcoming ? color.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Icon(
                    isUpcoming ? Icons.access_time : Icons.check_circle,
                    color: isUpcoming ? Colors.yellow : Colors.green,
                  ),
                  title: Text(
                    schedule.time,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          isUpcoming ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    schedule.route,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              )
            ];
            if (schedule.route.contains("(VILAR)")) {
              tiles.add(
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "OBS: O VILAR passa no bairro VILAR antes de ir para a rodoviária",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
            return tiles;
          }).toList(),
        ),
      ),
    );
  }
}

void main() => runApp(const MaterialApp(
      home: BusSchedulePage(),
      debugShowCheckedModeBanner: false,
    ));
