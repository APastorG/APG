## APG : A highly-parameterized VHDL library

This project is the result of a master's thesis, whose aim was to design a highly-parameterized, flexible and optimized library using state-of-the-art algorithms and models in order to implement complex algorithms, such as new FFT architectures.

As a proof of concept a ~27.000 VHDL statements CM FFT was implemented and verified, although its content remains out of the scope of a MIT license.

This library contains designs for:
- Counters
- Adders
- Real constant multipliers
- Real constant dividers
- Average calculators
- Complex constant multipliers
- Butterfly circuits
- Rotators
- Permutation circuits

#Tools
The tools that were used in simulation were Modelsim-Altera 10.4d and Active-HDL Student Version. The latter allows for the use of Matlab scripts inside VHDL code, feature which is used to obtain the optimum decomposition of bit permutations.

For synthesis, Vivado 2016.2 was used, as it does support needed VHDL 2008 features, such as the possibility of declaring ports of multidimensional unconstrained vector types.

#Design files
There exist common files to all modules, which are placed in the general folder.
- common_data_types_pkg, common_pkg: types, functions, procedures, ...
- fixed_float_types, fixed_generic_pkg: fixed point package which belongs to the VHDL 2008 standard, adapted so as to be usable with Vivado
- tb_pkg: some testbench functionalities

Each module may be formed by several files, differentiated by their suffix:
- _core: where the algorithm is carried out
- no suffix: the instantiatable file, is an interface to the core.
- _pkg: package with specific functionality to the module
- _tb: testbench

Additionally, a separation between signed and unsigned may exist, indicated with the suffixes _s/_u.

#Innovations
A novel approach was created to implement algorithms which rely on dynamic data in pure VHDL. This method is based on VHDL files with dual behavior depending on whether it is simulation or synthesis. In simulation a file is generated with the solution, which is read in the synthesis step. This was used to implement a decomposition algorithm that yields the optimal multiplierless multiple constant multiplication.

A novel method to automatically place pipelines was also created. Through a generic, the designer selects the pipelining level (minimum, high, ...) and a specific amount of the potential pipelines is automatically placed (0%, 75%, ...).