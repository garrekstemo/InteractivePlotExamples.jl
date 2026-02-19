using GLMakie

f(x) = exp(-x / 2)

xs = range(0, 10, length=100)
ys = f.(xs)

x1 = Observable(1.0)
x2 = 3.0
y1 = @lift(f($x1))
y2 = f(x2)

slope = @lift(($y1 - y2) / ($x1 - x2))
intercept = @lift($y1 - $slope * $x1)
secant_ys = @lift($slope .* xs .+ $intercept)


fig = Figure(size = (450, 400))
ax = Axis(fig[1, 1], yticks = LinearTicks(5))

vlines!(x1, linestyle = :dash, color = :gray)
vlines!(x2, linestyle = :dash, color = :gray)

hlines!(y1, linestyle = :dash, color = :gray)
hlines!(y2, linestyle = :dash, color = :gray)

lines!(xs, ys)
lines!(xs, secant_ys, color = :indigo)
scatter!(x1, y1, color = :orangered)
scatter!(x2, y2, color = :orangered)


label_visible = @lift($x1 == 1.0)
text!(0.3, 0.95, text = "f(x)", fontsize = 20, font = :bold, visible = label_visible)
text!(@lift(($x2 - $x1)), 0.9, text = "x + h", align = (:center, :top), fontsize = 16, font = :bold, visible = label_visible)
text!(6, @lift($y1 - y2), text = "f(x + h)", align = (:right, :center), fontsize = 16, font = :bold, visible = label_visible)

xlims!(ax, 0, 7)
ylims!(ax, 0, 1.1)
hidedecorations!(ax, grid = false)
fig

framerate = 60
pause_frames = 120  # 2 second pause at 60 fps
pause_timestamps = fill(1.0, pause_frames)
pause_end = fill(2.99, pause_frames)
animation_timestamps = range(1, 2.99, length = 480)
timestamps = vcat(pause_timestamps, animation_timestamps, pause_end)

record(fig, "tangent_line.mp4", timestamps, framerate = framerate) do t
    x1[] = t
end