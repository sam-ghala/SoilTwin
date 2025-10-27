# lets visualize this stuff

function plot_solution(phi, res, duration, α=1.0)
    z_grid = 0.0:0.01:1.0
    t_grid = 0.0:(duration/200):duration
    ψ_predict = [first(phi([z, t], res.u)) for z in z_grid, t in t_grid]
    ψ_dimensional = ψ_predict ./ α
    θ_predict = ψ_to_θ.(ψ_dimensional)
    hours = t_grid ./ 3600
    plt1 = heatmap(hours, z_grid, θ_predict, 
                   yflip=true, color=:blues, 
                   xlabel="Time (hours)", ylabel="Depth (m)", 
                   title="Moisture Content",
                   clim=(0.05, 0.45))

    plt2 = heatmap(hours, z_grid, ψ_predict, 
                   yflip=true, color=:viridis,
                   xlabel="Time (hours)", ylabel="Depth (m)", 
                   title="Pressure Head (m)",
                   clim=(-10, 0))
    
    p = plot(plt1, plt2, layout=(1,2), size=(1200, 400))
    display(p)
end
