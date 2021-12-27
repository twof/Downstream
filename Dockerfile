FROM swift:5.5.2

RUN git clone -b 0.2.0 https://github.com/twof/Downstream.git && \
   cd Downstream && \
   swift build -c release && \
   cp -f .build/release/downstream /usr/local/bin/downstream