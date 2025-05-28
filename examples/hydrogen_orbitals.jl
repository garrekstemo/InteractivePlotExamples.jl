using GLMakie
using ClassicalOrthogonalPolynomials
using HarmonicOrthogonalPolynomials

function sph2cart(r, θ, ϕ)
    x = r * sin(θ) * cos(ϕ)
    y = r * sin(θ) * sin(ϕ)
    z = r * cos(θ)
    return x, y, z
end

function cart2sph(x, y, z)
    r = sqrt(x^2 + y^2 + z^2)
    θ = acos(z / r)
    ϕ = atan(y, x)
    return r, θ, ϕ
end

function R_nl(n, l, r)
    ρ = 2r / n
    norm = sqrt((2 / n)^3 * factorial(n - l - 1) / (2 * n * factorial(n + l)))
    return norm * exp(-ρ / 2) * (ρ^l) * laguerrel(n - l - 1, 2l + 1, ρ)
end

function ψ_nlm(n, l, m, x, y, z)
    r, θ, ϕ = cart2sph(x, y, z)
    R = R_nl(n, l, r)
    Y = sphericalharmonicy(l, m, θ, ϕ)
    return R * Y
end

function orbital_density(n, l, m, x, y, z)
    N = length(x)
    ψ_real = zeros(Float64, N, N, N)
    density = zeros(Float64, N, N, N)

    for i in eachindex(x), j in eachindex(y), k in eachindex(z)
        ψ = ψ_nlm(n, l, m, x[i], y[j], z[k])
        ψ_real[i, j, k] = real(ψ)
        density[i, j, k] = abs2(ψ)
    end
    return density
end

n = Observable(5)
l = Observable(1)
m = Observable(0)
rmax = 25
N = 200
x = y = z = range(-rmax, rmax, length = N)
ρ = @lift(orbital_density($(n), $(l), $(m), x, y, z))
ρ = @lift($(ρ) ./ maximum($(ρ)))


cmap = :Egypt
# cmap = :deep
# cmap = :thermal

f = Figure(size = (2000, 1000),
    fontsize = 14)
Label(f[0, 1], "Hydrogen Atom Orbitals", tellwidth = false)

tb = Textbox(f[2, 1], placeholder = "nlm",
    tellwidth = false,
    )

on(tb.stored_string) do s
    n[], l[], m[] = parse(Int, s[1]), parse(Int, s[2]), parse(Int, s[3])
    println("n=$(to_value(n)), l=$(to_value(l)), m=$(to_value(m))")
end

ax1 = Axis3(f[1, 1])
isoval = 0.42
# volume!(x[1]..x[end], y[1]..y[end], z[1]..z[end], ψ_real,
#     algorithm = :iso,
#     isovalue = -isoval,
#     colormap = :RdBu,
#     )
# volume!(x[1]..x[end], y[1]..y[end], z[1]..z[end], ψ_real,
#     algorithm = :iso,
#     isovalue = isoval,
#     colormap = :RdBu,
#     )

volume!(x[1]..x[end], y[1]..y[end], z[1]..z[end], ρ,
    colormap = cmap,
    # transparency = true
    )

zslice = length(z) ÷ 2
zmin, zmax = minimum(z), maximum(z)
ρ_xy = @lift(dropdims(sum($(ρ), dims=3), dims=3))
ρ_xz = @lift(dropdims(sum($(ρ), dims=2), dims=2))
ρ_yz = @lift(dropdims(sum($(ρ), dims=1), dims=1))
ρ_slice = @lift($(ρ)[zslice, :, :])

contour!(x, y, ρ_xy,
    levels = 20,
    colormap = cmap,
    transformation = (:xy, zmin),
    transparency = true)
contour!(x, y, ρ_xz,
    levels = 20,
    colormap = cmap,
    transformation = (:xz, zmax),
    transparency = true)
contour!(x, y, ρ_yz,
    levels = 20,
    colormap = cmap,
    transformation = (:yz, zmax),
    transparency = true)


ax2 = Axis(f[1, 2], title = "Cut Plane through z", aspect = 1)

heatmap!(x, y, ρ_slice,
    colormap = cmap,
    )

f
