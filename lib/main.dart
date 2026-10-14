import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// ───────────────────────── palette & type ─────────────────────────
class C {
  static const cream = Color(0xFFFFF6F9);
  static const petal = Color(0xFFFFE1EC);
  static const candy = Color(0xFFFFB3D1);
  static const rose = Color(0xFFFF6FA5);
  static const berry = Color(0xFFC2185B);
  static const plum = Color(0xFF4A1530);
  static const lilac = Color(0xFFEBD8FF);
  static const peach = Color(0xFFFFDCCB);
}

TextStyle serif(double s,
        {Color c = C.plum, FontWeight w = FontWeight.w700, FontStyle st = FontStyle.normal}) =>
    GoogleFonts.playfairDisplay(fontSize: s, color: c, fontWeight: w, fontStyle: st, height: 1.08);
TextStyle sans(double s, {Color c = C.plum, FontWeight w = FontWeight.w400}) =>
    GoogleFonts.dmSans(fontSize: s, color: c, fontWeight: w, height: 1.65);
TextStyle hand(double s, {Color c = C.berry}) =>
    GoogleFonts.caveat(fontSize: s, color: c, fontWeight: FontWeight.w700, height: 1.1);

Future<void> go(String u) => launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication);

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Prerna Patil ♡ Portfolio',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: C.cream,
          colorScheme: ColorScheme.fromSeed(seedColor: C.rose),
        ),
        home: const Home(),
      );
}

// ───────────────────────── reusable motion widgets ─────────────────────────
/// Fades + slides its child in the first time it scrolls into view.
class Reveal extends StatefulWidget {
  final Widget? child;
  final Widget Function(bool shown)? builder;
  final int delay;
  final double dx, dy;
  const Reveal({super.key, this.child, this.builder, this.delay = 0, this.dx = 0, this.dy = 40});
  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> {
  bool _seen = false, _go = false;
  ScrollPosition? _p;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _p?.removeListener(_check);
    _p = Scrollable.maybeOf(context)?.position;
    _p?.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (_seen || !mounted) return;
    final o = context.findRenderObject();
    if (o is! RenderBox || !o.attached || !o.hasSize) return;
    if (o.localToGlobal(Offset.zero).dy < MediaQuery.of(context).size.height * 0.95) {
      _seen = true;
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) setState(() => _go = true);
      });
    }
  }

  @override
  void dispose() {
    _p?.removeListener(_check);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        opacity: _go ? 1 : 0,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(_go ? 0 : widget.dx, _go ? 0 : widget.dy, 0),
          child: widget.builder?.call(_go) ?? widget.child!,
        ),
      );
}

class Hover extends StatefulWidget {
  final Widget Function(bool hovering) builder;
  final VoidCallback? onTap;
  final double lift;
  const Hover({super.key, required this.builder, this.onTap, this.lift = 10});
  @override
  State<Hover> createState() => _HoverState();
}

class _HoverState extends State<Hover> {
  bool h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) => setState(() => h = true),
        onExit: (_) => setState(() => h = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(0, h ? -widget.lift : 0, 0),
            child: widget.builder(h),
          ),
        ),
      );
}

class Floaty extends StatefulWidget {
  final Widget child;
  final double amp, phase;
  const Floaty({super.key, required this.child, this.amp = 16, this.phase = 0});
  @override
  State<Floaty> createState() => _FloatyState();
}

class _FloatyState extends State<Floaty> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(
      vsync: this, duration: Duration(milliseconds: 2600 + (widget.phase * 900).round()))
    ..repeat(reverse: true);
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: c,
        child: widget.child,
        builder: (_, ch) => Transform.translate(
            offset: Offset(0, Curves.easeInOut.transform(c.value) * widget.amp - widget.amp / 2),
            child: ch),
      );
}

class ShimmerText extends StatefulWidget {
  final String text;
  final TextStyle style;
  const ShimmerText(this.text, this.style, {super.key});
  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText> with SingleTickerProviderStateMixin {
  late final AnimationController c =
      AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: c,
        builder: (_, __) => ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (r) => LinearGradient(
            begin: Alignment(-1 + 2 * c.value, -0.3),
            end: Alignment(1 + 2 * c.value, 0.3),
            tileMode: TileMode.repeated,
            colors: const [C.berry, C.rose, C.candy, C.rose, C.berry],
          ).createShader(r),
          child: Text(widget.text, style: widget.style.copyWith(color: Colors.white)),
        ),
      );
}

class Typewriter extends StatefulWidget {
  final List<String> words;
  final TextStyle style;
  const Typewriter(this.words, this.style, {super.key});
  @override
  State<Typewriter> createState() => _TypewriterState();
}

class _TypewriterState extends State<Typewriter> {
  Timer? t;
  int w = 0, i = 0, hold = 0;
  bool del = false;
  @override
  void initState() {
    super.initState();
    t = Timer.periodic(const Duration(milliseconds: 70), (_) {
      if (hold > 0) {
        hold--;
        return;
      }
      final len = widget.words[w].length;
      if (!del) {
        if (i < len) {
          i++;
        } else {
          hold = 20;
          del = true;
        }
      } else if (i > 0) {
        i--;
      } else {
        del = false;
        w = (w + 1) % widget.words.length;
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Text('${widget.words[w].substring(0, i)}${DateTime.now().millisecond < 500 ? '|' : ' '}',
          style: widget.style);
}

/// Endlessly scrolling ribbon of words.
class Marquee extends StatefulWidget {
  final List<String> items;
  const Marquee(this.items, {super.key});
  @override
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> with SingleTickerProviderStateMixin {
  final sc = ScrollController();
  late final Ticker tk;
  @override
  void initState() {
    super.initState();
    tk = createTicker((d) {
      if (sc.hasClients) sc.jumpTo(d.inMilliseconds * 0.055);
    })..start();
  }

  @override
  void dispose() {
    tk.dispose();
    sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView.builder(
        controller: sc,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (_, i) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Text('✦  ${widget.items[i % widget.items.length]}',
                style: serif(26, c: Colors.white, st: FontStyle.italic, w: FontWeight.w600)),
          ),
        ),
      );
}

// ───────────────────────── painted background ─────────────────────────
class BgPainter extends CustomPainter {
  final double t;
  BgPainter(this.t);
  @override
  void paint(Canvas canvas, Size s) {
    final a = t * 2 * math.pi;
    void blob(double fx, double fy, double r, Color c, double ph) {
      final ctr = Offset(s.width * (fx + 0.07 * math.sin(a + ph)), s.height * (fy + 0.07 * math.cos(a + ph)));
      canvas.drawCircle(
          ctr,
          r,
          Paint()
            ..shader = RadialGradient(colors: [c.withOpacity(.55), c.withOpacity(0)])
                .createShader(Rect.fromCircle(center: ctr, radius: r)));
    }

    blob(.1, .15, 380, C.candy, 0);
    blob(.92, .3, 340, C.lilac, 2);
    blob(.25, .85, 420, C.peach, 4);
    blob(.85, .9, 360, C.candy, 1);

    for (int i = 0; i < 26; i++) {
      final x = ((i * 37) % 100) / 100 * s.width;
      final y = (((i * 53) % 100) / 100 * s.height + math.sin(a * 2 + i) * 14);
      final tw = .35 + .45 * (0.5 + 0.5 * math.sin(a * 3 + i * 1.7));
      final r = 4.0 + (i % 4) * 2.2;
      final p = Path()
        ..moveTo(x, y - r * 2)
        ..quadraticBezierTo(x, y, x + r * 2, y)
        ..quadraticBezierTo(x, y, x, y + r * 2)
        ..quadraticBezierTo(x, y, x - r * 2, y)
        ..quadraticBezierTo(x, y, x, y - r * 2);
      canvas.drawPath(p, Paint()..color = (i % 3 == 0 ? Colors.white : C.rose).withOpacity(tw));
    }
  }

  @override
  bool shouldRepaint(BgPainter o) => true;
}

// ───────────────────────── small UI bits ─────────────────────────
Widget pill(String t, {Color bg = C.petal, Color fg = C.berry, double sz = 13}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white, width: 2)),
      child: Text(t, style: sans(sz, c: fg, w: FontWeight.w700)),
    );

Widget sticker(String t, Color bg, IconData i, double rot) => Transform.rotate(
      angle: rot,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [BoxShadow(color: C.rose.withOpacity(.28), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(i, size: 16, color: C.berry),
          const SizedBox(width: 6),
          Text(t, style: sans(14, c: C.berry, w: FontWeight.w700)),
        ]),
      ),
    );

Widget btn(String t, VoidCallback f, {bool filled = true}) => Hover(
      onTap: f,
      lift: 4,
      builder: (h) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          gradient: filled ? const LinearGradient(colors: [C.rose, C.berry]) : null,
          color: filled ? null : (h ? C.petal : Colors.white.withOpacity(.6)),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: filled ? Colors.white : C.rose, width: 2),
          boxShadow: [BoxShadow(color: C.rose.withOpacity(h ? .5 : .28), blurRadius: h ? 30 : 18, offset: const Offset(0, 10))],
        ),
        child: Text(t, style: sans(15, c: filled ? Colors.white : C.berry, w: FontWeight.w700)),
      ),
    );

BoxDecoration card({Color c = Colors.white, double r = 30, bool glow = false}) => BoxDecoration(
      color: c.withOpacity(.82),
      borderRadius: BorderRadius.circular(r),
      border: Border.all(color: Colors.white, width: 3),
      boxShadow: [BoxShadow(color: C.rose.withOpacity(glow ? .4 : .16), blurRadius: glow ? 40 : 24, offset: const Offset(0, 14))],
    );

// ───────────────────────── data (from resume) ─────────────────────────
class Proj {
  final String emoji, title, role, date;
  final List<String> pts, tech;
  final List<Color> g;
  const Proj(this.emoji, this.title, this.role, this.date, this.pts, this.tech, this.g);
}

const projects = [
  Proj('🩺', 'OmniCare', 'Team Lead · AI healthcare platform', 'Jul 2026', [
    'Led a 4-member team building a RAG-based medical assistant that answers from uploaded reports with source citations.',
    'Designed a 6-agent AI architecture and a Patient Digital Twin for healthcare insights.',
    'Built the React frontend and Flask backend on a ChromaDB vector store.',
  ], ['React', 'Flask', 'Gemini', 'RAG', 'ChromaDB'], [Color(0xFFFFD6E7), Color(0xFFFFB3D1)]),
  Proj('🌸', 'MedClear AI', 'Solo Developer · Medical report explainer', 'May 2026', [
    'Turns diagnostic reports into plain-language summaries and flags abnormal values.',
    'Gemini API for explanations; Flask backend on Render, React frontend on Vercel.',
  ], ['Python', 'Flask', 'React', 'Gemini API'], [Color(0xFFEBD8FF), Color(0xFFFFD1E6)]),
  Proj('💸', 'Crescent', 'Team Lead · Micro-investment fintech', 'Oct 2025', [
    'Spare-change investing platform with 7+ React pages for portfolio and P&L tracking.',
    'FastAPI backend with Razorpay Sandbox payments.',
  ], ['React', 'FastAPI', 'Razorpay'], [Color(0xFFFFE6D6), Color(0xFFFFC2D9)]),
];

// Breast-cancer research entry. Fill these in and the card appears under
// "Research & recognition". While bcTitle is empty, the card stays hidden.
const bcTag = 'Research';
const bcTitle = '';
const bcDetail = '';

const skills = {
  '🧠  AI / ML': ['LLMs', 'RAG', 'Multi-Agent Systems', 'Prompt Engineering', 'Gemini API', 'ChromaDB'],
  '💻  Languages': ['Java', 'Python', 'SQL', 'C', 'JavaScript'],
  '🕸  Web & Backend': ['React', 'Flask', 'FastAPI', 'REST APIs', 'HTML', 'CSS'],
  '📊  Data & Analytics': ['Pandas', 'NumPy', 'Plotly', 'Streamlit', 'Tableau', 'Power BI', 'Excel'],
  '📚  CS Fundamentals': ['DSA', 'OOP', 'DBMS', 'OS', 'Software Engineering', 'Computer Networks'],
  '☁️  Cloud & Tools': ['GCP', 'Git', 'GitHub', 'Vercel', 'Render', 'Figma', 'Notion'],
};

// ───────────────────────── page ─────────────────────────
class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late final AnimationController bg =
      AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();
  final sc = ScrollController();
  final mouse = ValueNotifier<Offset>(const Offset(-300, -300));
  static const names = ['home', 'about', 'journey', 'work', 'skills', 'honors', 'contact'];
  final keys = List.generate(names.length, (_) => GlobalKey());

  @override
  void dispose() {
    bg.dispose();
    sc.dispose();
    super.dispose();
  }

  void jump(int i) => Scrollable.ensureVisible(keys[i].currentContext!,
      duration: const Duration(milliseconds: 1000), curve: Curves.easeInOutCubic);

  bool isM(BuildContext c) => MediaQuery.of(c).size.width < 860;

  @override
  Widget build(BuildContext context) {
    final m = isM(context);
    return Scaffold(
      body: MouseRegion(
        onHover: (e) => mouse.value = e.position,
        child: Stack(children: [
          Positioned.fill(
              child: AnimatedBuilder(animation: bg, builder: (_, __) => CustomPaint(painter: BgPainter(bg.value)))),
          SingleChildScrollView(
            controller: sc,
            child: Column(children: [
              sec(0, m, hero(m), top: 110),
              band(),
              sec(1, m, about(m)),
              sec(2, m, journey(m)),
              sec(3, m, work(m)),
              sec(4, m, skillsSec(m)),
              sec(5, m, honors(m)),
              sec(6, m, contact(m)),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Text('made with Flutter & way too much pink ♡', style: hand(24)),
              ),
            ]),
          ),
          ValueListenableBuilder<Offset>(
            valueListenable: mouse,
            builder: (_, o, __) => AnimatedPositioned(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              left: o.dx - 130,
              top: o.dy - 130,
              child: IgnorePointer(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [C.rose.withOpacity(.22), C.rose.withOpacity(0)])),
                ),
              ),
            ),
          ),
          nav(m),
        ]),
      ),
    );
  }

  Widget sec(int i, bool m, Widget child, {double top = 90}) => Container(
        key: keys[i],
        padding: EdgeInsets.fromLTRB(m ? 22 : 48, top, m ? 22 : 48, 20),
        child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1120), child: child)),
      );

  Widget head(bool m, String tag, String a, String b) => Reveal(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tag, style: hand(30)),
            Text.rich(TextSpan(text: '$a ', style: serif(m ? 36 : 52), children: [
              TextSpan(text: b, style: serif(m ? 36 : 52, c: C.rose, st: FontStyle.italic)),
            ])),
          ]),
        ),
      );

  // ── nav
  Widget nav(bool m) => Positioned(
        top: 14,
        left: 0,
        right: 0,
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutBack,
            builder: (_, v, ch) =>
                Opacity(opacity: v.clamp(0.0, 1.0), child: Transform.translate(offset: Offset(0, -34 * (1 - v)), child: ch)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: m ? 18 : 26, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.55),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('prerna ♡', style: hand(30)),
                    const SizedBox(width: 18),
                    if (!m)
                      for (int i = 1; i < names.length; i++)
                        Hover(
                          lift: 2,
                          onTap: () => jump(i),
                          builder: (h) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(names[i],
                                style: sans(15, c: h ? C.rose : C.plum, w: FontWeight.w600)),
                          ),
                        )
                    else
                      PopupMenuButton<int>(
                        icon: const Icon(Icons.favorite, color: C.rose),
                        color: C.cream,
                        onSelected: jump,
                        itemBuilder: (_) => [
                          for (int i = 0; i < names.length; i++)
                            PopupMenuItem(value: i, child: Text(names[i], style: sans(15, c: C.berry))),
                        ],
                      ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );

  // ── hero
  Widget hero(bool m) {
    final left = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Reveal(delay: 200, child: pill('✿ open to internships')),
      const SizedBox(height: 18),
      Reveal(delay: 350, child: Text('hi, i\'m', style: hand(40))),
      Reveal(delay: 500, child: ShimmerText('Prerna\nPatil', serif(m ? 64 : 100))),
      const SizedBox(height: 18),
      Reveal(
        delay: 700,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('I build ', style: sans(m ? 20 : 24, w: FontWeight.w600)),
          Typewriter(
            const ['AI-powered apps', 'RAG pipelines', 'pretty interfaces', 'full-stack dreams', 'things that heal'],
            sans(m ? 20 : 24, c: C.rose, w: FontWeight.w800),
          ),
        ]),
      ),
      const SizedBox(height: 14),
      Reveal(
        delay: 850,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'Computer Science undergraduate building AI-powered, full-stack applications in Python, Java, React and Flask/FastAPI — with RAG, LLM integration and vector databases, on a strong DSA foundation.',
            style: sans(16.5, c: C.plum.withOpacity(.8)),
          ),
        ),
      ),
      const SizedBox(height: 28),
      Reveal(
        delay: 1000,
        child: Wrap(spacing: 14, runSpacing: 14, children: [
          btn('see my work ✦', () => jump(3)),
          btn('say hello ♡', () => jump(6), filled: false),
        ]),
      ),
      const SizedBox(height: 30),
      Reveal(
        delay: 1150,
        child: Wrap(spacing: 10, children: [
          for (final l in const [
            ['GitHub', 'https://github.com/prerna-patil01'],
            ['LinkedIn', 'https://www.linkedin.com/in/patilprerna91'],
            ['LeetCode', 'https://leetcode.com/u/prerna-5b2'],
          ])
            Hover(onTap: () => go(l[1]), lift: 4, builder: (_) => pill(l[0], bg: Colors.white, sz: 14)),
        ]),
      ),
    ]);

    final right = Reveal(
      delay: 500,
      dx: 60,
      dy: 0,
      child: SizedBox(
        width: 400,
        height: 500,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned(
            top: 30,
            left: 40,
            child: Floaty(
              amp: 12,
              child: Transform.rotate(
                angle: -.06,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: C.rose.withOpacity(.35), blurRadius: 40, offset: const Offset(0, 24))],
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        'assets/prerna.jpg',
                        width: 270,
                        height: 310,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (_, __, ___) => Container(
                          width: 270,
                          height: 310,
                          decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [C.candy, C.lilac, C.peach])),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('prerna ♡ 2026', style: hand(30)),
                  ]),
                ),
              ),
            ),
          ),
          Positioned(top: 0, right: 0, child: Floaty(phase: 1, child: sticker('LeetCode 1606', C.peach, Icons.bolt, .08))),
          Positioned(top: 190, left: -20, child: Floaty(phase: 2, amp: 20, child: sticker('RAG · LLMs', C.lilac, Icons.auto_awesome, -.1))),
          Positioned(bottom: 60, right: -10, child: Floaty(phase: 3, child: sticker('CGPA 8.72', C.petal, Icons.favorite, .06))),
          Positioned(bottom: 0, left: 30, child: Floaty(phase: 1.5, amp: 22, child: sticker('Team Lead ×4', Colors.white, Icons.star, -.05))),
        ]),
      ),
    );

    return Column(children: [
      m
          ? Column(children: [left, const SizedBox(height: 40), right])
          : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(child: left), right]),
      const SizedBox(height: 60),
      Reveal(
        child: Wrap(spacing: 18, runSpacing: 18, alignment: WrapAlignment.center, children: [
          stat(1606, 'LeetCode rating', 0),
          stat(1456, 'CodeChef rating', 0),
          stat(8.72, 'CGPA / 10', 2),
          stat(100, 'Top-100 · Myntra WeForShe', 0, pre: 'Top '),
        ]),
      ),
    ]);
  }

  Widget stat(double v, String label, int dec, {String pre = ''}) => Reveal(
        builder: (shown) => Hover(
          builder: (h) => Container(
            width: 250,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
            decoration: card(glow: h),
            child: Column(children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: shown ? v : 0),
                duration: const Duration(milliseconds: 1800),
                curve: Curves.easeOutCubic,
                builder: (_, x, __) =>
                    Text('$pre${dec > 0 ? x.toStringAsFixed(dec) : x.round()}', style: serif(46, c: C.rose, st: FontStyle.italic)),
              ),
              Text(label, style: sans(14, w: FontWeight.w600)),
            ]),
          ),
        ),
      );

  Widget band() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 70),
        child: Transform.rotate(
          angle: -.022,
          child: Container(
            height: 66,
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [C.rose, C.berry, C.rose])),
            child: const Marquee(['Python', 'React', 'RAG', 'Gemini', 'ChromaDB', 'FastAPI', 'Flask', 'Java', 'GCP', 'Multi-Agent Systems', 'DSA']),
          ),
        ),
      );

  // ── about
  Widget about(bool m) {
    final edu = [
      ['2024 – 2028', 'B.Tech, Computer Science & Engineering', 'BVRIT Hyderabad College of Engineering for Women · CGPA 8.72'],
      ['2022 – 2024', 'Intermediate (MPC)', 'Narayana Junior College · 90.2%'],
      ['2020 – 2022', 'SSC', 'Narayana High School · CGPA 9.8'],
    ];
    final story = Reveal(
      dx: -40,
      dy: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: card(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('a little about me ✿', style: hand(32)),
          const SizedBox(height: 10),
          Text(
            'I\'m a computer science student in Hyderabad who loves turning AI into something people can actually use — from a RAG-based medical assistant to a micro-investing app.\n\nI lead hackathon teams, represent 60+ classmates as Class Representative, and keep my public-speaking muscles warm as an active Toastmasters member.\n\nI speak English, Hindi, Telugu and Marathi.',
            style: sans(16.5),
          ),
        ]),
      ),
    );
    final eduCard = Reveal(
      dx: 40,
      dy: 0,
      delay: 150,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: card(c: C.petal),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('education ✿', style: hand(32)),
          const SizedBox(height: 12),
          for (final e in edu)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e[0], style: hand(22, c: C.rose)),
                Text(e[1], style: sans(16.5, w: FontWeight.w700)),
                Text(e[2], style: sans(14.5, c: C.plum.withOpacity(.75))),
              ]),
            ),
        ]),
      ),
    );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      head(m, 'who’s this girl?', 'About', 'me'),
      m
          ? Column(children: [story, const SizedBox(height: 22), eduCard])
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: story),
              const SizedBox(width: 26),
              Expanded(child: eduCard),
            ]),
    ]);
  }

  // ── journey
  Widget journey(bool m) {
    const items = [
      [
        'Jul 2026',
        'AI/ML Trainee · Tech Trek 3.0',
        'Jio Institute, Mumbai',
        'Selected for a summer industry-immersion program with hands-on training in RAG, GANs and LLM implementation.\nVisited Reliance Corporate Park and Fynd to study enterprise AI deployment.\nLed a 4-member team to build OmniCare during the program hackathon.',
      ],
      [
        'May – Jun 2026',
        'AI Intern · Software Development Intern',
        'CodeAlpha & Cognifyz IT Solutions (remote)',
        'Built and evaluated ML models in Python across two remote internships; contributed to software development, testing and maintenance using Git.',
      ],
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      head(m, 'where i’ve been', 'My', 'journey'),
      Container(
        margin: const EdgeInsets.only(left: 14),
        decoration: const BoxDecoration(border: Border(left: BorderSide(color: C.candy, width: 3))),
        child: Column(children: [
          for (int i = 0; i < items.length; i++)
            Reveal(
              delay: i * 150,
              child: Stack(clipBehavior: Clip.none, children: [
                Positioned(
                  left: -25,
                  top: 10,
                  child: Floaty(
                    amp: 6,
                    phase: i.toDouble(),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: C.rose,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [BoxShadow(color: C.rose.withOpacity(.5), blurRadius: 14)],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: m ? 26 : 44, bottom: 28),
                  child: Hover(
                    builder: (h) => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: card(glow: h),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(items[i][0], style: hand(28, c: C.rose)),
                        Text(items[i][1], style: serif(m ? 22 : 28)),
                        Text(items[i][2], style: sans(15, c: C.berry, w: FontWeight.w700)),
                        const SizedBox(height: 10),
                        for (final line in items[i][3].split('\n'))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('✿  $line', style: sans(15.5)),
                          ),
                      ]),
                    ),
                  ),
                ),
              ]),
            ),
        ]),
      ),
    ]);
  }

  // ── work (pinterest-style staggered collage)
  Widget work(bool m) {
    Widget pc(int i) => Reveal(
          delay: i * 160,
          builder: (_) => Hover(
            lift: 14,
            builder: (h) => AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: projects[i].g),
                borderRadius: BorderRadius.circular(34),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [BoxShadow(color: C.rose.withOpacity(h ? .5 : .2), blurRadius: h ? 44 : 22, offset: const Offset(0, 18))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  AnimatedScale(
                      scale: h ? 1.35 : 1,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.elasticOut,
                      child: Text(projects[i].emoji, style: const TextStyle(fontSize: 42))),
                  const Spacer(),
                  pill(projects[i].date, bg: Colors.white),
                ]),
                const SizedBox(height: 14),
                Text(projects[i].title, style: serif(34)),
                Text(projects[i].role, style: hand(24)),
                const SizedBox(height: 12),
                for (final p in projects[i].pts)
                  Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('✿  $p', style: sans(14.5))),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [for (final t in projects[i].tech) pill(t, bg: Colors.white.withOpacity(.8), sz: 12.5)]),
              ]),
            ),
          ),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      head(m, 'things i made', 'Selected', 'work'),
      m
          ? Column(children: [for (int i = 0; i < 3; i++) Padding(padding: const EdgeInsets.only(bottom: 24), child: pc(i))])
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: pc(0)),
              const SizedBox(width: 24),
              Expanded(child: Padding(padding: const EdgeInsets.only(top: 70), child: pc(1))),
              const SizedBox(width: 24),
              Expanded(child: Padding(padding: const EdgeInsets.only(top: 24), child: pc(2))),
            ]),
    ]);
  }

  // ── skills
  Widget skillsSec(bool m) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        head(m, 'my toolbox', 'Skills &', 'stack'),
        Wrap(spacing: 22, runSpacing: 22, children: [
          for (final (i, e) in skills.entries.indexed)
            Reveal(
              delay: i * 100,
              child: Hover(
                builder: (h) => Container(
                  width: m ? double.infinity : 350,
                  padding: const EdgeInsets.all(26),
                  decoration: card(glow: h, c: i.isEven ? Colors.white : C.petal),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.key, style: serif(22)),
                    const SizedBox(height: 14),
                    Wrap(spacing: 8, runSpacing: 8, children: [for (final s in e.value) pill(s, bg: i.isEven ? C.petal : Colors.white)]),
                  ]),
                ),
              ),
            ),
        ]),
      ]);

  // ── honors
  Widget honors(bool m) {
    const wins = [
      ['🏆', 'Top-100 Participant — Team Lead', 'Myntra “WeForShe” Hackathon · garment fit-prediction engine'],
      ['🚀', 'Team Lead', 'BITS Pilani Hackathon & Pivot Ideathon'],
      ['🎤', 'Class Representative & Toastmaster', '60+ students · active Toastmasters member'],
    ];
    const certs = [
      'Google Cloud Computing Foundations · Google Cloud (2025)',
      'Data Analytics Virtual Experience · Deloitte (Forage)',
      'Software Engineering Virtual Experience · J.P. Morgan (Forage)',
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      head(m, 'gold stars', 'Research &', 'recognition'),
      Reveal(
        child: Hover(
          builder: (h) => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: card(glow: h, c: C.lilac),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('📖  Co-author · Accepted Manuscript', style: hand(28)),
              const SizedBox(height: 6),
              Text('Transforming Engineering Education Through STEM: Empowering the Next Generation of Innovators',
                  style: serif(m ? 21 : 26, w: FontWeight.w600, st: FontStyle.italic)),
              const SizedBox(height: 8),
              Text('Patent Gen Beta 2025, Edition 1 · ISBN book publication', style: sans(15, w: FontWeight.w600)),
            ]),
          ),
        ),
      ),
      if (bcTitle.isNotEmpty) ...[
        const SizedBox(height: 24),
        Reveal(
          delay: 120,
          child: Hover(
            builder: (h) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: card(glow: h, c: C.petal),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('🎀  $bcTag', style: hand(28)),
                const SizedBox(height: 6),
                Text(bcTitle, style: serif(m ? 21 : 26, w: FontWeight.w600, st: FontStyle.italic)),
                if (bcDetail.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(bcDetail, style: sans(15, w: FontWeight.w600)),
                ],
              ]),
            ),
          ),
        ),
      ],
      const SizedBox(height: 24),
      Wrap(spacing: 22, runSpacing: 22, children: [
        for (final (i, w) in wins.indexed)
          Reveal(
            delay: i * 120,
            child: Hover(
              builder: (h) => Container(
                width: m ? double.infinity : 350,
                padding: const EdgeInsets.all(26),
                decoration: card(glow: h),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(w[0], style: const TextStyle(fontSize: 34)),
                  const SizedBox(height: 8),
                  Text(w[1], style: sans(17, w: FontWeight.w800)),
                  Text(w[2], style: sans(14.5, c: C.plum.withOpacity(.75))),
                ]),
              ),
            ),
          ),
      ]),
      const SizedBox(height: 28),
      Reveal(
        child: Wrap(spacing: 12, runSpacing: 12, children: [for (final c in certs) pill('🎀  $c', bg: Colors.white, sz: 13.5)]),
      ),
    ]);
  }

  // ── contact
  Widget contact(bool m) => Reveal(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: m ? 44 : 70, horizontal: m ? 24 : 60),
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [C.rose, C.berry]),
            borderRadius: BorderRadius.circular(48),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [BoxShadow(color: C.rose.withOpacity(.5), blurRadius: 50, offset: const Offset(0, 24))],
          ),
          child: Column(children: [
            Floaty(child: Text('✦', style: serif(46, c: Colors.white))),
            Text('let’s build something pretty', textAlign: TextAlign.center, style: serif(m ? 34 : 56, c: Colors.white, st: FontStyle.italic)),
            const SizedBox(height: 10),
            Text('Open to internships and collaborations. My inbox is always open.',
                textAlign: TextAlign.center, style: sans(17, c: Colors.white)),
            const SizedBox(height: 28),
            Wrap(spacing: 14, runSpacing: 14, alignment: WrapAlignment.center, children: [
              Hover(
                onTap: () => go('mailto:prernapatil071@gmail.com'),
                lift: 4,
                builder: (_) => pill('prernapatil071@gmail.com', bg: Colors.white, sz: 15),
              ),
              Hover(
                onTap: () => go('tel:+919381886215'),
                lift: 4,
                builder: (_) => pill('+91 93818 86215', bg: Colors.white, sz: 15),
              ),
              Hover(onTap: () => go('https://www.linkedin.com/in/patilprerna91'), lift: 4, builder: (_) => pill('LinkedIn', bg: C.petal, sz: 15)),
              Hover(onTap: () => go('https://github.com/prerna-patil01'), lift: 4, builder: (_) => pill('GitHub', bg: C.petal, sz: 15)),
            ]),
          ]),
        ),
      );
}