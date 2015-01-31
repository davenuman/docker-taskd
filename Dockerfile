
FROM base/archlinux

RUN pacman --noconfirm -Syyu
RUN pacman-db-upgrade
RUN pacman --noconfirm -S base-devel
RUN pacman --noconfirm -S git cmake

# Get taskd
RUN git clone -b 1.1.0 https://git.tasktools.org/scm/tm/taskd.git taskd-build
WORKDIR /taskd-build

# make
RUN cmake -DCMAKE_BUILD_TYPE=release .
RUN make

# test
WORKDIR /taskd-build/test
RUN make && ./run_all

# Install taskd
WORKDIR /taskd-build
RUN make install

RUN taskd
