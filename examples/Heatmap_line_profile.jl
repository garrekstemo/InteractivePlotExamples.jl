using GLMakie


function gaussian(p,x,y)
    a,x0,y0,σx,σy = p
    ans = a * exp( - ((x - x0)^2 / (2 * σx^2 ) + (y - y0)^2 / (2 * σy^2 )))
    return ans
end




# Configure the settings for heatmap
f = Figure(resolution = (1200,2000),fontsize = 30)
display(f)
DataInspector(f)
ax1 = Axis(f[1,1],title = "2D Gaussian function",xlabel  = "x",xlabelsize = 40,ylabel = "y",ylabelsize = 40)


# Create plot data and 2D gaussian parameters
x = range(1,200,2000)
y = range(1,100,1000)
p = [50,100,50,10,10]


# Create z data for heatmap based on x, y, and p
z = zeros(Float64,length(x),length(y))

for (i,j) in enumerate(x)
    for (m,n) in enumerate(y)
        z[i,m] = gaussian(p,j,n)
    end
end


# Plot heatmap
heatmap!(ax1,x,y,z,interactivity = true)


# Configure the settings for 2D figures
ax2 = Axis(f[2,1],title = "Gaussian function x",xlabel  = "x",xlabelsize = 40,ylabel = "z",ylabelsize = 40)
ax3 = Axis(f[3,1],title = "Gaussian function y",xlabel  = "y",xlabelsize = 40,ylabel = "z",ylabelsize = 40)


# Define observables
x_line = Observable(100.0)
y_line = Observable(50.0)

x_data = Observable(z[:,500])
y_data = Observable(z[1000,:])

# Plot straight lines indicating the position of the cursor
vlines!(ax1,x_line,color = :red)
hlines!(ax1,y_line,color = :red)


# Plot 2D figures
lines!(ax2,x,x_data)
lines!(ax3,y,y_data)


# on-do Block(executed when triggered)
on(events(ax1).mouseposition) do mpos
    x_pos = mouseposition(ax1.scene)[1]
    y_pos = mouseposition(ax1.scene)[2]

    x_line[] =  trunc(Int,mouseposition(ax1.scene)[1])
    y_line[] =  trunc(Int,mouseposition(ax1.scene)[2])

    x_data[] = z[:,findfirst(isapprox(y_pos,atol = 0.2),y)]
    y_data[] = z[findfirst(isapprox(x_pos,atol = 0.2),x),:]
    
    # autolimits!(ax2)
    # autolimits!(ax3)
end