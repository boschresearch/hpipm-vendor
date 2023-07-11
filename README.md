[![License](https://img.shields.io/badge/License-Apache%202-blue.svg)](LICENSE)
[![License](https://img.shields.io/badge/License-BSD_2--Clause-orange.svg)](https://opensource.org/licenses/BSD-2-Clause)

# The hpipm-vendor repository
A vendor package for hpipm. In detail, this repository contains one CMake package:

*   [hpipm-vendor](hpipm-vendor/) provides a vendor package for hpipm.

Technical information on the interfaces and use of these packages is given in the README.md files in the corresponding subfolders.


## Purpose of the project

The software is not ready for production use. It has neither been developed nor tested for a specific use case. However, the license conditions of the applicable Open Source licenses allow you to adapt the software to your needs. Before using it in a safety relevant setting, make sure that the software fulfills your requirements and adjust it according to any applicable safety standards (e.g. ISO 26262).


## Requirements, how to build, test, install, use, etc.

Clone repository into you ROS workspace:
```bash
cd <workspace>/src
git clone https://github.com/boschresearch/blasfeo-vendor.git
```

clone dependencies:
```bash
cd <workspace>/src/blasfeo-vendor
vcs import < dependencies.repos
```


## License

hpipm-vendor is open-sourced under the Apache-2.0 license. See the [LICENSE](LICENSE) file for details.

For a list of other open source components included in hpipm-vendor, see the file [3rd-party-licenses.txt](3rd-party-licenses.txt).


## Quality assurance

The colcon_test tool is used for quality assurances, which includes cpplint, uncrustify, flake8, xmllint and various other tools.


## Known issues/limitations

Please notice the following issues/limitations:

* This vendor package only builds the C library, and not the Python and Matlab/Octave interfaces.

