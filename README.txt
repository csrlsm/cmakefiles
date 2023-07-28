1. oxd_libsec和oxd_preda可分别独立编译。其中oxd_libsec编译后lib文件会自动存放一份至oxd_libsec/lib对应的目录下，oxd_preda编译过程会寻找该目录下的oxd_libsec库文件。

2. 根据oxd_libsec的CONFIGURATION_TYPE【Debug | Release】再编译oxd_preda相同的CONFIGURATION_TYPE

3. oxd_preda各子模块（preda_engine、transpiler、chain_smiu）默认编译到各自对应的目录下，最后再执行INSTALL操作，集中存放一份到build/PREDA/bin目录下

4. 3rdParty相关压缩包下载解压、安装包等操作独立执行，可通过-DDOWNLOAD_OPS=[ON |OFF] -DBUNDLE_OPS=[ON |OFF]进行开关，节省编译时间。ipp对应的包文件在oxd_libsec执行，开关参数一样，其余3rdParty包在oxd_preda执行

5. CMake_rules.txt 设置oxd_preda的全局引用的变量及函数，只在oxd_preda项目引用。