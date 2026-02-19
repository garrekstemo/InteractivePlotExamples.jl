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
    return ψ_real, density
end