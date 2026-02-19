using GLMakie
using ClassicalOrthogonalPolynomials


f = Figure()
ax = Axis(f[1, 1])

ns = 0:4
xs = range(-1, 1, length=100)
for n in ns
    ys = [legendrep(n, x) for x in xs]
    lines!(xs, ys, label="P_$n(x)")
end

ax2 = Axis(f[2, 1])

ns = 0:4
xs = range(-5, 20, length=100)
for n in ns
    ys = [laguerrel(n, x) for x in xs]
    lines!(xs, ys, label="P_$n(x)")
end
ylims!(ax2, -10, 20)

f