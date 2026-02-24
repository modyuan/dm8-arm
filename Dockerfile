# ===================== 构建阶段 =====================
FROM macrosan/kylin:v10-sp1 AS builder

# 构建参数
ARG INSTALL_FILE="DMInstall.bin"
ARG CONFIG_XML="db_install.xml"

# 构建时的路径变量
ENV SOFT_DIR="/soft"
ENV INSTALL_DIR="/opt/dmdbms"

# 创建达梦需要的用户和组
RUN groupadd -g 12349 dinstall && \
    useradd -u 12345 -g dinstall -m -d /home/dmdba -s /bin/bash dmdba

# 创建目录并授权
RUN mkdir -p ${SOFT_DIR} ${INSTALL_DIR} && \
    chown -R dmdba:dinstall ${SOFT_DIR} ${INSTALL_DIR}

# 拷贝安装文件
COPY ${INSTALL_FILE} ${CONFIG_XML} ${SOFT_DIR}/

# 安装 + 清理
RUN chmod a+x ${SOFT_DIR}/${INSTALL_FILE} && \
    ${SOFT_DIR}/${INSTALL_FILE} -q ${SOFT_DIR}/${CONFIG_XML} && \
    rm -rf ${SOFT_DIR}
    
# ===================== 最终运行镜像 =====================
FROM macrosan/kylin:v10-sp1

# 环境变量
ENV INSTALL_DIR="/opt/dmdbms"
ENV DM_HOME="${INSTALL_DIR}/bin"
ENV DATA_DIR="/opt/data"
ENV CREATE_DB_FILE="db_instance.sh"

ENV PATH="${PATH}:${DM_HOME}"
ENV LD_LIBRARY_PATH="${DM_HOME}"

# 创建运行用户
RUN groupadd -g 12349 dinstall && \
    useradd -u 12345 -g dinstall -m -d /home/dmdba -s /bin/bash dmdba && \
    mkdir -p ${DATA_DIR} && \
    chown -R dmdba:dinstall ${DATA_DIR}

COPY --from=builder ${INSTALL_DIR} ${INSTALL_DIR}
COPY ${CREATE_DB_FILE} /

RUN chmod a+x /${CREATE_DB_FILE}

WORKDIR ${DM_HOME}
CMD ["/db_instance.sh"]
