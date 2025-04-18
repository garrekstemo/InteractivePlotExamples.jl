using GLMakie

s(t, L, T) = L * (3 * (t / T)^2 - 2 * (t / T)^3)
v(t, L, T) = (6 * L / T^2) * t * (1 - t / T)

t = 0:0.1:10
L = 100
T = 7
distance = s.(t, L, T)
velocity = v.(t, L, T)


f = Figure()
ax = Axis(f[1, 1], title = "Tangent line", xlabel = "t", ylabel = "s")
ylims!(ax, 0 - L * 0.03, L * 1.05)

lines!(t, distance)

t0 = 3.0
xpoint = Observable(t0)
ypoint = Observable(s(t0, L, T))
tangent_line = Observable(v(t0, L, T) * (t .- t0) .+ s(t0, L, T))
lines!(t, tangent_line, color = :tomato)
scatter!(xpoint, ypoint, color = :tomato)


on(events(ax).mouseposition) do mpos
    xpoint[] = mouseposition(ax.scene)[1]
    if xpoint[] < 0
        xpoint[] = 0
    elseif xpoint[] > 10
        xpoint[] = 10
    end
    ypoint[] = s(xpoint[], L, T)

    tangent_line[] = v(xpoint[], L, T) * (t .- xpoint[]) .+ s(xpoint[], L, T)
end
f