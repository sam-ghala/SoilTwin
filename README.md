# SoilTwin.jl

[![Build Status](https://github.com/sam-ghala/SoilTwin.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/sam-ghala/SoilTwin.jl/actions/workflows/CI.yml?query=branch%3Amain)

A digital twin system for agricultural irrigation management using Physics-Informed Neural Networks (PINNs) to predict soil moisture dynamics.

## Roadmap

- Physics-Informed Neural Networks for soil moisture prediction
- Solves Richards equation for variably saturated flow
- Multi-station validation framework
- Integration with International Soil Moisture Network (ISMN) data
- Irrigation decision support based on crop requirements

## Installation

Development version:
```julia
using Pkg
Pkg.develop(url="https://github.com/sam-ghala/SoilTwin.jl")
```

## Quick Start
```julia
using SoilTwin

```

## Research Background

This package implements methodologies for Physics-Informed Neural Networks to solve the Richards equation for soil moisture prediction.

## Key Components

- **Physics Modeling**: Richards equation implementation with PINNs
- **Data Integration**: ISMN sensor data processing
- **Parameter Estimation**: Soil hydraulic property inference
- **Prediction Engine**: Multi-day soil moisture forecasting
- **Decision Support**: Irrigation recommendations based on crop thresholds

## Data

### ISMN Data Structure

This package uses soil moisture data from the [International Soil Moisture Network (ISMN)](https://ismn.earth/).

Download station data and place `.stm` files in the `raw_data/` folder (ignored by git).

**Expected structure:**
```
raw_data/
├── Metadata.xml
├── README.md
├── ISMN_network_descriptions.txt
├── ISMN_qualityflags_description.txt
├── Readme.txt
├── Berlin/
    └── Stoetten/
        ├── DWD_DWD_St...20250825.stm
        ├── DWD_DWD_St...20250825.stm
        └── DWD_DWD_St..._variables.csv
```

**To get started:**
1. Register at [ISMN](https://ismn.earth/)
2. Download station data (networks: RSMN, SMOSMANIA, etc.)
3. Extract to `raw_data/` directory

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Citation

If you use this software in your research, please cite:
```bibtex
@software{SoilTwin,
  author = {Sam Ghalayini},
  title = {SoilTwin.jl: Digital Twin for Agricultural Irrigation},
  year = {2025},
  url = {https://github.com/sam-ghala/SoilTwin.jl}
}
```

## Contact

Sam Ghalayini - ghalayini.sj@gmail.com

Project Link: [https://github.com/sam-ghala/SoilTwin.jl](https://github.com/sam-ghala/SoilTwin.jl)