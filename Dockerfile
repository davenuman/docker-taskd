FROM base/archlinux

RUN pacman --noconfirm -Syyu
RUN pacman-db-upgrade
RUN pacman --noconfirm -S base-devel
RUN pacman --noconfirm -S git cmake

# Clone taskd git repo
RUN git clone -b 1.1.0 https://git.tasktools.org/scm/tm/taskd.git taskd-build
WORKDIR /taskd-build

# compile taskd
RUN cmake -DCMAKE_BUILD_TYPE=release .
RUN make

# Run tests
WORKDIR /taskd-build/test
RUN make && ./run_all

# Install taskd
WORKDIR /taskd-build
RUN make install

# Create user and verify that taskd is installed
ENV TASKDDATA /data/taskd
VOLUME /data
RUN useradd -d $TASKDDATA taskd
RUN taskd

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 53589
