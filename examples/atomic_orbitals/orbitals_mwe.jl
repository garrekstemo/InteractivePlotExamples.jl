using GLMakie
using ClassicalOrthogonalPolynomials
using HarmonicOrthogonalPolynomials


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
    return ψ_real, density
end

n, l, m = 3, 2, 0
rmax = 30
x = y = z = range(-rmax, rmax, length = 200)
ψ, ρ = orbital_density(n, l, m, x, y, z)
ψ ./= maximum(ψ)

zslice = length(z) ÷ 2
ψ_slice = ψ[zslice, :, :]


f = Figure(size = (1000, 400))
cmap = :Egypt

ax1 = Axis3(f[1, 1])
volume!(x[1]..x[end], y[1]..y[end], z[1]..z[end],
    ψ,
    colormap = cmap,
    )

ax2 = Axis(f[1, 2][1, 1], title = "Cut Plane through z", aspect = 1)

hm = heatmap!(x, y, ψ_slice,
    colormap = cmap,
    )
cb = Colorbar(f[1, 2][1, 2], hm)

colsize!(f.layout, 2, Aspect(1, 1.0))
f

# save("images/orbitals_mwe.jpg", f)