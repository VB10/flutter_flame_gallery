import 'package:flame/components.dart';

/// A thrown body: [velocity] bends under [gravity] while it turns at [spin]
/// radians per second.
mixin Ballistic on PositionComponent {
  Vector2 get velocity;
  double get gravity;
  double get spin;

  void fly(double dt) {
    velocity.y += gravity * dt;
    position.addScaled(velocity, dt);
    angle += spin * dt;
  }
}
