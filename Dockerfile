FROM swift:5.5.2

RUN git clone -b 0.3.0 https://github.com/twof/Downstream.git && \
   cd Downstream && \
   swift build -c release && \
   chmod +x .build/release/downstream && \
   cp -f .build/release/downstream /usr/local/bin/downstream

ENTRYPOINT ["downstream"]
