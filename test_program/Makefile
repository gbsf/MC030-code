
export CXX=g++
export CXXFLAGS=-Wall -Wno-sign-compare -ggdb3 -O0 --std=c++20

ALL = fp_test pocketfft_demo \
	paranoia_Fp16 paranoia_Fp32 paranoia_Fp64 paranoia_Fp16a paranoia_Fp8 \
	blackscholes_Fp16 blackscholes_Fp32 blackscholes_Fp64 blackscholes_Fp16a blackscholes_Fp8 blackscholes_float blackscholes_double \
	swaptions_Fp16 swaptions_Fp32 swaptions_Fp64 swaptions_Fp16a swaptions_Fp8 swaptions_float swaptions_double \
	sobel_Fp16 sobel_Fp32 sobel_Fp64 sobel_float sobel_double \
	cover

all: $(ALL)

paranoia_%.o: paranoia.cpp fp_class.hpp
	$(CXX) $(CXXFLAGS) -DNOSIGNAL -DNOPAUSE -DFPNEW -DFLOAT=$(patsubst paranoia_%.o,%,$@) -c $< -o $@

fp_test.o: main.cpp fp_class.hpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

pocketfft_demo.o: pocketfft_demo.cc fp_class.hpp
	$(CXX) $(CXXFLAGS) -DPOCKETFFT_NO_VECTORS -DPOCKETFFT_NO_MULTITHREADING -c $< -o $@

blackscholes_%.o: blackscholes.c fp_class.hpp
	$(CXX) $(CXXFLAGS) -Dfptype=$(patsubst blackscholes_%.o,%,$@) -c $< -o $@

swaptions_%: $(wildcard swaptions/*.cpp) $(wildcard swaptions/*.c) fp_class.hpp
	$(MAKE) -C swaptions clean
	$(MAKE) -C swaptions DEF="-DFTYPE=$(subst swaptions_,,$@)"
	cp swaptions/swaptions $@

sobel_%.o: sobel.cpp fp_class.hpp
	$(CXX) $(CXXFLAGS) -DFPTYPE=$(patsubst sobel_%.o,%,$@) -c $< -o $@

cover.o: cover.cpp fp_class.hpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

fp_init.o: fp_init.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

%: %.o fp_init.o
	$(CXX) $^ -o $@

clean:
	rm -f $(ALL) *.o swaptions/*.o

.PHONY: all clean
