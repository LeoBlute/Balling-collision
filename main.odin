package xpbd

import rl "vendor:raylib"

ball :: struct {
   radius: f32,
   position: rl.Vector2,
   velocity: rl.Vector2,
   mass: f32
}

main :: proc() {
   rl.SetTraceLogLevel(.WARNING)
   rl.InitWindow(1280, 720, "")

   balls: [20]ball
   for &b, i in balls {
      fi := cast(f32)i
      b.radius = 40
      b.mass = rl.PI * b.radius * b.radius * b.radius
      b.position = rl.Vector2{b.radius + fi * b.radius * b.radius, 50}
      b.velocity = rl.Vector2{auto_cast(i / 2) * 100, (i % 3 == 0) ? 1 : -1 * 1000}
   }

   gravity := rl.Vector2{0, 0}
   restitution :f32= 1
   for !rl.WindowShouldClose() {
      rl.ClearBackground(rl.BLACK)
      rl.BeginDrawing()
      defer rl.EndDrawing()

      delta := rl.GetFrameTime()
      for &b, i in balls {
         b.velocity -= gravity * delta
         b.position += b.velocity * delta

         for &b2 in balls[i+1:] {

            dir := b2.position - b.position
            d := rl.Vector2Length(dir)
            if d == 0 || d > b.radius + b2.radius {
               continue
            }

            dir *= 1 / d

            corr := (b.radius + b2.radius - d) / 2
            b.position  -= dir * corr
            b2.position += dir * corr

            v1 := rl.Vector2DotProduct(b.velocity, dir)
            v2 := rl.Vector2DotProduct(b2.velocity, dir)

            m1 := b.mass
            m2 := b2.mass

            newv1 := (m1 * v1 + m2 * v2 - m2 * (v1 - v2) * restitution) / (m1 + m2)
            newv2 := (m1 * v1 + m2 * v2 - m1 * (v2 - v1) * restitution) / (m1 + m2)

            b.velocity  += dir * (newv1 - v1)
            b2.velocity += dir * (newv2 - v2)
         }

         if b.position.x < b.radius {
            b.position.x = b.radius
            b.velocity.x = -b.velocity.x
         }
         if b.position.x > auto_cast rl.GetRenderWidth() - b.radius {
            b.position.x = auto_cast rl.GetRenderWidth() - b.radius
            b.velocity.x = -b.velocity.x
         }
         if b.position.y > auto_cast rl.GetRenderHeight() - b.radius{
            b.position.y = auto_cast rl.GetRenderHeight() - b.radius
            b.velocity.y = -b.velocity.y
         }
         if b.position.y < b.radius {
            b.position.y = b.radius
            b.velocity.y = -b.velocity.y
         }
      }

      for &b in balls {
         translated_position := rl.Vector2{b.position.x, -b.position.y + auto_cast rl.GetRenderHeight()}
         rl.DrawCircleV(translated_position, b.radius, rl.RED)
      }

      rl.GuiSlider({0, 0, 200, 50}, "restitution", "", &restitution, 0, 1)
      rl.DrawText("Restitution", 210, 0, 50, rl.WHITE)
      rl.GuiSlider({0, 50, 200, 50}, "Gravity", "", &gravity.y, 0, 1000)
      rl.DrawText("Gravity", 210, 50, 50, rl.WHITE)
   }
}