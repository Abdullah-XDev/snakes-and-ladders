import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;

void main() => runApp(const SnakesAndLaddersApp());

class SnakesAndLaddersApp extends StatelessWidget {
const SnakesAndLaddersApp({super.key});
@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
theme: ThemeData(scaffoldBackgroundColor: const Color(0xFF1A1A2E)),
home: const GameScreen(),
);
}
}

// ─── Data ────────────────────────────────────────────────────
final Map<int, int> ladders = {
2: 38, 7: 14, 8: 31, 15: 26, 21: 42,
28: 84, 36: 44, 51: 67, 71: 91, 78: 98, 87: 94,
};
final Map<int, int> snakes = {
16: 6, 46: 25, 49: 11, 62: 19, 64: 60,
74: 53, 89: 68, 92: 88, 95: 75, 99: 78,
};

Offset posToCenter(int pos, double cell) {
if (pos < 1 || pos > 100) return const Offset(-1, -1);
int rowFromBottom = (pos - 1) ~/ 10;
int row = 9 - rowFromBottom;
int colInRow = (pos - 1) % 10;
int col = (rowFromBottom % 2 == 0) ? colInRow : (9 - colInRow);
return Offset((col + 0.5) * cell, (row + 0.5) * cell);
}

// ─── Game Screen ─────────────────────────────────────────────
class GameScreen extends StatefulWidget {
const GameScreen({super.key});
@override
State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
with SingleTickerProviderStateMixin {
int p1 = 0, p2 = 0, turn = 1, diceVal = 0, winner = 0;
bool rolling = false, gameOver = false;
String status = "دور اللاعب الأول!", moveMsg = "";
late AnimationController _dc;
late Animation<double> _da;

@override
void initState() {
super.initState();
_dc = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
_da = CurvedAnimation(parent: _dc, curve: Curves.bounceOut);
}

@override
void dispose() {
_dc.dispose();
super.dispose();
}

void roll() {
if (rolling || gameOver) return;
setState(() { rolling = true; moveMsg = ""; });
_dc.forward(from: 0);
Future.delayed(const Duration(milliseconds: 250), () {
int r = Random().nextInt(6) + 1;
setState(() { diceVal = r; });
Future.delayed(const Duration(milliseconds: 300), () => apply(r));
});
}

void apply(int r) {
int cur = turn == 1 ? p1 : p2;
int np = cur + r;
if (np > 100) {
setState(() {
rolling = false;
moveMsg = "رقم $r — لا يكفي! تحتاج ${100 - cur} بالضبط";
turn = turn == 1 ? 2 : 1;
status = turn == 1 ? "دور اللاعب الأول" :"دور اللاعب الثاني!";
});
return;
}
setState(() {
moveMsg = "رقم $r → موقع $np";
if (turn == 1) p1 = np; else p2 = np;
});
Future.delayed(const Duration(milliseconds: 450), () {
if (ladders.containsKey(np)) {
int dest = ladders[np]!;
setState(() {
moveMsg = "🪜 سلم من $np إلى $dest!";
if (turn == 1) p1 = dest; else p2 = dest;
});
Future.delayed(const Duration(milliseconds: 600), checkWin);
} else if (snakes.containsKey(np)) {
int dest = snakes[np]!;
setState(() {
moveMsg = "🐍 أفعى من $np إلى $dest!";
if (turn == 1) p1 = dest; else p2 = dest;
});
Future.delayed(const Duration(milliseconds: 600), checkWin);
} else {
checkWin();
}
});
}

void checkWin() {
if (p1 == 100 || p2 == 100) {
setState(() {
gameOver = true;
winner = p1 == 100 ? 1 : 2;
rolling = false;
status ="🎉 فاز اللاعب 🎉 $winner!";
});
} else {
setState(() {
rolling = false;
turn = turn == 1 ? 2 : 1;
status = turn == 1 ? "دور اللاعب الأول!" :"دور اللاعب الثاني!";
});
}
}

void reset() {
setState(() {
p1 = 0; p2 = 0; turn = 1; diceVal = 0;
gameOver = false; winner = 0; rolling = false;
status = "دور اللاعب الأول!"; moveMsg = "";
});
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFF1A1A2E),
body: Stack(
children: [
SafeArea(
child: Column(
children: [
Padding(
padding: const EdgeInsets.symmetric(vertical: 10),
child: Text("🐍  الحية والسلم  🪜",

style: const TextStyle(color: Colors.white, fontSize: 24,
fontWeight: FontWeight.bold,
shadows: [Shadow(color: Color(0xFF6C63FF), blurRadius: 14)]),
textAlign: TextAlign.center),
),
Row(mainAxisAlignment: MainAxisAlignment.center, children: [
_chip(1, p1, const Color(0xFFFF6B6B)),
const SizedBox(width: 12),
_chip(2, p2, const Color(0xFF4ECDC4)),
]),
Padding(padding: const EdgeInsets.symmetric(vertical: 3),
child: Text(status,
style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 15),
textAlign: TextAlign.center)),
Expanded(
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 6),
child: AspectRatio(
aspectRatio: 1.0,
child: _Board(p1: p1, p2: p2),
),
),
),
if (moveMsg.isNotEmpty)
Container(
margin: const EdgeInsets.symmetric(vertical: 4),
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
decoration: BoxDecoration(
color: moveMsg.contains("🐍") ? const Color(0x55E74C3C)
: moveMsg.contains("🪜") ? const Color(0x5544FF88)
: const Color(0x33FFFFFF),
borderRadius: BorderRadius.circular(20)),
child: Text(moveMsg,
style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
textAlign: TextAlign.center)),
const Padding(padding: EdgeInsets.symmetric(vertical: 8),
child: Text("[Eng.Abdullah Esh]",
style: TextStyle(color: Color.fromARGB(255, 206, 140, 232),fontSize: 20,fontWeight: FontWeight.w500,
),
textAlign: TextAlign.center,),),
_diceRow(),
const SizedBox(height: 8),
],
),
),
if (gameOver) _winOverlay(),
],
),
);
}

Widget _chip(int id, int pos, Color c) {
bool active = turn == id && !gameOver;
return AnimatedContainer(
duration: const Duration(milliseconds: 300),
padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
decoration: BoxDecoration(
color: active ? c.withOpacity(0.25) : c.withOpacity(0.08),
border: Border.all(color: active ? c : c.withOpacity(0.3), width: active ? 2.2 : 1.2),
borderRadius: BorderRadius.circular(22)),
child: Row(children: [
Container(width: 20, height: 20, decoration: BoxDecoration(
color: c, shape: BoxShape.circle,
boxShadow: active ? [BoxShadow(color: c, blurRadius: 7)] : [])),
const SizedBox(width: 7),
Text("اللاعب $id : $pos",
style: TextStyle(color: Colors.white, fontSize: 13,
fontWeight: active ? FontWeight.bold : FontWeight.normal)),
]),
);
}

Widget _diceRow() {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
AnimatedBuilder(
animation: _da,
builder: (ctx, child) {
double s = rolling && _da.value < 0.5 ? 6.0 * sin(_da.value * 25) : 0;
return Transform.translate(offset: Offset(s, 0), child: child!);
},
child: Container(width: 64, height: 64,
decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.45), blurRadius: 10, offset: const Offset(0, 3))]),
child: Center(child: _diceFace(diceVal))),
),
const SizedBox(width: 18),
GestureDetector(onTap: roll,
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
decoration: BoxDecoration(
gradient: LinearGradient(colors: (gameOver || rolling)
? [Colors.grey, Colors.grey.shade600]
: [const Color(0xFF6C63FF), const Color(0xFF9B59B6)]),
borderRadius: BorderRadius.circular(28),
boxShadow: (gameOver || rolling) ? [] : [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 3))]),
child: const Text("🎲  اضغط النرد", 
style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
)),
]),
);
}

Widget _diceFace(int v) {
if (v == 0) return const Icon(Icons.help_outline, color: Colors.grey, size: 24);
const List<List<List<double>>> L = [
[], [[.5,.5]], [[.25,.25],[.75,.75]],
[[.25,.25],[.5,.5],[.75,.75]],
[[.25,.25],[.75,.25],[.25,.75],[.75,.75]],
[[.25,.25],[.75,.25],[.5,.5],[.25,.75],[.75,.75]],
[[.25,.2],[.75,.2],[.25,.5],[.75,.5],[.25,.8],[.75,.8]],
];
const double b = 48, d = 9;
return SizedBox(width: b, height: b,
child: Stack(children: L[v].map((p) => Positioned(
left: p[0]*b - d/2, top: p[1]*b - d/2,
child: Container(width: d, height: d,
decoration: const BoxDecoration(color: Color(0xFF1A1A2E), shape: BoxShape.circle))
)).toList()));
}

Widget _winOverlay() {
Color wc = winner == 1 ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4);
return Positioned.fill(child: Container(
color: Colors.black.withOpacity(0.88),
child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
const Text("🎉", style: TextStyle(fontSize: 72)),
const SizedBox(height: 10),
Text("فاز اللاعب $winner!", style: TextStyle(color: wc, fontSize: 40,
fontWeight: FontWeight.bold, shadows: [Shadow(color: wc, blurRadius: 18)]),
textAlign: TextAlign.center),
const SizedBox(height: 6),
const Text("تهانيّ!", style: TextStyle(color: Colors.white70, fontSize: 20)),
const SizedBox(height: 28),
GestureDetector(onTap: reset,
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 13),
decoration: BoxDecoration(
gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)]),
borderRadius: BorderRadius.circular(28),
boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 3))]),
child: const Text("🔄  لعب مجدداً",
style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
)),
]),
));
}
}

// ═══════════════════════════════════════════════════════════════
// ─── Board ────────────────────────────────────────────────────
class _Board extends StatelessWidget {
final int p1, p2;
const _Board({required this.p1, required this.p2});

@override
Widget build(BuildContext context) {
return LayoutBuilder(builder: (ctx, con) {
double sz = min(con.maxWidth, con.maxHeight);
double cell = sz / 10.0;
return SizedBox(width: sz, height: sz,
child: Stack(children: [
_grid(cell),
CustomPaint(painter: _BoardPainter(cell: cell), size: Size(sz, sz)),
_token(p1, cell, sz, const Color(0xFFFF6B6B), 1),
_token(p2, cell, sz, const Color(0xFF4ECDC4), 2),
]));
});
}

Widget _grid(double cell) {
List<Widget> cells = [];
for (int row = 0; row < 10; row++) {
for (int col = 0; col < 10; col++) {
int rfb = 9 - row;
int pos = (rfb % 2 == 0) ? rfb * 10 + col + 1 : rfb * 10 + (9 - col) + 1;
bool even = (row + col) % 2 == 0;
Color base = even ? const Color(0xFF16213E) : const Color(0xFF0F3460);
if (ladders.containsKey(pos)) base = const Color(0x551E4D2B);
if (snakes.containsKey(pos)) base = const Color(0x554D1E1E);
if (pos == 100) base = const Color(0x55FFD700);
cells.add(Positioned(
left: col * cell, top: row * cell, width: cell, height: cell,
child: Container(
decoration: BoxDecoration(color: base,
border: Border.all(color: Colors.white.withOpacity(0.07), width: 0.5)),
child: Stack(children: [
Positioned(top: 2, left: 3,
child: Text("$pos", style: TextStyle(
color: pos == 100 ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.55),
fontSize: cell * 0.22,
fontWeight: pos == 100 ? FontWeight.bold : FontWeight.normal))),
if (pos == 100) Center(child: Text("⭐", style: TextStyle(fontSize: cell * 0.42))),
]),
),
));
}
}
return Stack(children: cells);
}

Widget _token(int pos, double cell, double sz, Color color, int id) {
double ts = cell * 0.52;
if (pos == 0) {
return Positioned(
left: (id == 1 ? 0.25 : 0.75) * cell - ts / 2,
top: sz - ts * 0.7,
child: _tokenDot(ts, color, id));
}
Offset c = posToCenter(pos, cell);
double ox = 0;
if (id == 1 && p1 == p2 && p1 != 0) ox = -cell * 0.14;
if (id == 2 && p1 == p2 && p2 != 0) ox = cell * 0.14;
return AnimatedPositioned(
duration: const Duration(milliseconds: 450),
curve: Curves.easeInOut,
left: c.dx - ts / 2 + ox,
top: c.dy - ts / 2,
child: _tokenDot(ts, color, id));
}

Widget _tokenDot(double sz, Color c, int id) {
return Container(width: sz, height: sz,
decoration: BoxDecoration(color: c, shape: BoxShape.circle,
border: Border.all(color: Colors.white, width: 2.2),
boxShadow: [
BoxShadow(color: c, blurRadius: 8, spreadRadius: 1.5),
BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3, offset: const Offset(0, 2))]),
child: Center(child: Text("$id",
style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))));
}
}

// ═══════════════════════════════════════════════════════════════
// ─── Board Painter ────────────────────────────────────────────
class _BoardPainter extends CustomPainter {
final double cell;
_BoardPainter({required this.cell});

@override
void paint(ui.Canvas canvas, ui.Size size) {
for (var e in ladders.entries) {
_drawLadder(canvas, posToCenter(e.key, cell), posToCenter(e.value, cell));
}
for (var e in snakes.entries) {
_drawSnake(canvas, posToCenter(e.key, cell), posToCenter(e.value, cell));
}
}

void _drawLadder(ui.Canvas canvas, Offset start, Offset end) {
double dx = end.dx - start.dx;
double dy = end.dy - start.dy;
double len = sqrt(dx * dx + dy * dy);
double angle = atan2(dy, dx);
double px = cos(angle + pi / 2) * 4.0;
double py = sin(angle + pi / 2) * 4.0;


ui.Paint rope = ui.Paint()
  ..color = const Color(0xFFB8860B)
  ..strokeWidth = 2.5
  ..strokeCap = ui.StrokeCap.round;

canvas.drawLine(ui.Offset(start.dx - px, start.dy - py), ui.Offset(end.dx - px, end.dy - py), rope);
canvas.drawLine(ui.Offset(start.dx + px, start.dy + py), ui.Offset(end.dx + px, end.dy + py), rope);

ui.Paint rung = ui.Paint()
  ..color = const Color(0xFFDEB887)
  ..strokeWidth = 2.5
  ..strokeCap = ui.StrokeCap.round;

int n = max(3, (len / (cell * 0.7)).toInt());
for (int i = 1; i <= n; i++) {
  double t = i / (n + 1);
  double cx = start.dx + dx * t;
  double cy = start.dy + dy * t;
  canvas.drawLine(ui.Offset(cx - px * 1.5, cy - py * 1.5), ui.Offset(cx + px * 1.2, cy + py * 1), rung);
}

ui.Paint glow = ui.Paint()..color = const Color(0xFF44FF88).withOpacity(0.8);
canvas.drawCircle(start, 5, glow);


}

void _drawSnake(ui.Canvas canvas, Offset head, Offset tail) {
double dx = tail.dx - head.dx;
double dy = tail.dy - head.dy;
double len = sqrt(dx * dx + dy * dy);
double angle = atan2(dy, dx);
double curve = len * 0.25;
double px = cos(angle + pi / 2) * curve;
double py = sin(angle + pi / 2) * curve;


ui.Offset p1 = ui.Offset(head.dx + dx * 0.25 + px, head.dy + dy * 0.25 + py);
ui.Offset mid = ui.Offset((head.dx + tail.dx) / 2, (head.dy + tail.dy) / 2);
ui.Offset p2 = ui.Offset(head.dx + dx * 0.75 - px, head.dy + dy * 0.75 - py);

ui.Path path = ui.Path();
path.moveTo(head.dx, head.dy);
path.quadraticBezierTo(p1.dx + px * 0.3, p1.dy + py * 0.3, p1.dx, p1.dy);
path.quadraticBezierTo(mid.dx - px * 0.0, mid.dy - py * 0.03, mid.dx, mid.dy);
path.quadraticBezierTo(p2.dx - px * 0.2, p2.dy - py * 0.2, p2.dx, p2.dy);
path.quadraticBezierTo(tail.dx + px * 0.3, tail.dy + py * 0.3, tail.dx, tail.dy);

ui.Paint outline = ui.Paint()
  ..color = const Color(0xFF7B241C)
  ..strokeWidth = 7.5
  ..strokeCap = ui.StrokeCap.round
  ..style = ui.PaintingStyle.stroke;
canvas.drawPath(path, outline);

ui.Paint body = ui.Paint()
  ..color = const Color(0xFFE74C3C)
  ..strokeWidth = 5
  ..strokeCap = ui.StrokeCap.round
  ..style = ui.PaintingStyle.stroke;
canvas.drawPath(path, body);

// Head
ui.Paint headFill = ui.Paint()..color = const Color(0xFFE74C3C);
canvas.drawCircle(head, 7.5, headFill);
ui.Paint headOutline = ui.Paint()
  ..color = const Color(0xFF7B241C)
  ..strokeWidth = 1.0
  ..style = ui.PaintingStyle.stroke;
canvas.drawCircle(head, 7.5, headOutline);

// Eyes
ui.Paint eyeW = ui.Paint()..color = const Color(0xFFFFFFFF);
canvas.drawCircle(ui.Offset(head.dx - 2.8, head.dy - 2.0), 2.8, eyeW);
canvas.drawCircle(ui.Offset(head.dx + 2.8, head.dy - 2.0), 2.8, eyeW);
ui.Paint pupil = ui.Paint()..color = const Color(0xFF000000);
canvas.drawCircle(ui.Offset(head.dx - 2.8, head.dy - 1.8), 1.3, pupil);
canvas.drawCircle(ui.Offset(head.dx + 2.8, head.dy - 1.8), 1.3, pupil);

// Tongue
ui.Paint tongue = ui.Paint()
  ..color = const Color(0xFFFF1744)
  ..strokeWidth = 1.5
  ..strokeCap = ui.StrokeCap.round;
double tAngle = atan2(dy, dx);
ui.Offset tBase = ui.Offset(head.dx + cos(tAngle) * 7.0, head.dy + sin(tAngle) * 7.0);
canvas.drawLine(tBase, ui.Offset(tBase.dx + cos(tAngle - 0.4) * 6, tBase.dy + sin(tAngle - 0.4) * 6), tongue);
canvas.drawLine(tBase, ui.Offset(tBase.dx + cos(tAngle + 0.4) * 6, tBase.dy + sin(tAngle + 0.4) * 6), tongue);


}

@override
bool shouldRepaint(_BoardPainter old) => old.cell != cell;
}