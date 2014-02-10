%module hotrodcs

%{
#include <infinispan/hotrod/BasicMarshaller.h>
#include <infinispan/hotrod/Builder.h>
#include <infinispan/hotrod/Configuration.h>
#include <infinispan/hotrod/ConfigurationBuilder.h>
#include <infinispan/hotrod/ConfigurationChildBuilder.h>
#include <infinispan/hotrod/ConnectionPoolConfiguration.h>
#include <infinispan/hotrod/ConnectionPoolConfigurationBuilder.h>
#include <infinispan/hotrod/Flag.h>
#include <infinispan/hotrod/Handle.h>
#include <infinispan/hotrod/Hash.h>
#include <infinispan/hotrod/ImportExport.h>
#include <infinispan/hotrod/Marshaller.h>
#include <infinispan/hotrod/MetadataValue.h>
#include <infinispan/hotrod/RemoteCache.h>
#include <infinispan/hotrod/RemoteCacheBase.h>
#include <infinispan/hotrod/RemoteCacheManager.h>
#include <infinispan/hotrod/ScopedBuffer.h>
#include <infinispan/hotrod/ServerConfiguration.h>
#include <infinispan/hotrod/ServerConfigurationBuilder.h>
#include <infinispan/hotrod/SslConfiguration.h>
#include <infinispan/hotrod/SslConfigurationBuilder.h>
#include <infinispan/hotrod/TimeUnit.h>
#include <infinispan/hotrod/Version.h>
#include <infinispan/hotrod/VersionedValue.h>
#include <infinispan/hotrod/defs.h>
#include <infinispan/hotrod/exceptions.h>
#include <infinispan/hotrod/types.h>
%}

/* Change the access modifier for the classes generated by SWIG to 'internal'. */
%pragma(csharp) moduleclassmodifiers="internal class"
%typemap(csclassmodifiers) SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) "internal class"
%typemap(csclassmodifiers) enum SWIGTYPE "internal enum"

/* Force a common interface between the 32 and 64 bit wrapper code. */
%include "hotrod_arch.i"

%include "exception.i"
%include "hotrod_exception.i"

%include "stdint.i"
%include "std_string.i"
%include "std_pair.i"
%include "std_map.i"
%include "std_vector.i"

#define SWIG_SHARED_PTR_SUBNAMESPACE tr1
%include "std_shared_ptr.i"
%shared_ptr(infinispan::hotrod::ByteArray)

// include order matters.
%include "infinispan/hotrod/ImportExport.h"

%include "infinispan/hotrod/TimeUnit.h"
%include "infinispan/hotrod/defs.h"

%rename(RootException) Exception;
%ignore "HotRodClientException";
%include std_except.i
%include "infinispan/hotrod/exceptions.h"

%include "infinispan/hotrod/ScopedBuffer.h"
%include "infinispan/hotrod/types.h"

%include "infinispan/hotrod/Flag.h"
%include "infinispan/hotrod/Handle.h"
%include "infinispan/hotrod/Hash.h"
%include "infinispan/hotrod/Version.h"

%include "infinispan/hotrod/VersionedValue.h"
%include "infinispan/hotrod/MetadataValue.h"

%include "infinispan/hotrod/Marshaller.h"
%include "infinispan/hotrod/BasicMarshaller.h"

%include "infinispan/hotrod/Builder.h"

%include "infinispan/hotrod/ConnectionPoolConfiguration.h"
%include "infinispan/hotrod/ServerConfiguration.h"
%include "infinispan/hotrod/SslConfiguration.h"
%include "infinispan/hotrod/Configuration.h"

%template(BuilderConf) infinispan::hotrod::Builder<infinispan::hotrod::Configuration>;
%template(BuilderServerConf) infinispan::hotrod::Builder<infinispan::hotrod::ServerConfiguration>;
%template(BuilderPoolConf) infinispan::hotrod::Builder<infinispan::hotrod::ConnectionPoolConfiguration>;
%template(BuilderSSLConf) infinispan::hotrod::Builder<infinispan::hotrod::SslConfiguration>;

%include "infinispan/hotrod/ConfigurationChildBuilder.h"
%include "infinispan/hotrod/ConnectionPoolConfigurationBuilder.h"
%include "infinispan/hotrod/ServerConfigurationBuilder.h"
%include "infinispan/hotrod/SslConfigurationBuilder.h"
%include "infinispan/hotrod/ConfigurationBuilder.h"

%template(HandleRemoteCacheManagerImpl) infinispan::hotrod::Handle<infinispan::hotrod::RemoteCacheManagerImpl>;
%template(HandleRemoteCacheImpl) infinispan::hotrod::Handle<infinispan::hotrod::RemoteCacheImpl>;

%include "infinispan/hotrod/RemoteCacheBase.h"
%include "infinispan/hotrod/RemoteCache.h"
%include "infinispan/hotrod/RemoteCacheManager.h"

%include "arrays_csharp.i"
%apply unsigned char INPUT[] {unsigned char* _bytes}
%apply unsigned char OUTPUT[] {unsigned char* dest_bytes}
%newobject infinispan::hotrod::BasicMarchaller<ByteArray>::unmarshall;

%inline{

#include <exception>
#include <string>

namespace infinispan {
namespace hotrod {

    class ByteArray {
    public:
        ByteArray() {
            /* Required if ByteArray is used as key in std::map. */
        }

        ByteArray(unsigned char* _bytes, int _size) : bytes(_bytes), size(_size) {
        }

        unsigned char* getBytes() const {
            return bytes;
        }

        void copyBytesTo(unsigned char* dest_bytes) {
            memcpy(dest_bytes, bytes, size);
        }

        int getSize() const {
            return size;
        }

        friend bool operator<(const ByteArray b1, const ByteArray b2);
        
    private:
        unsigned char* bytes;
        int size;
    };

    bool operator<(const ByteArray b1, const ByteArray b2) {
        /* Required if ByteArray is used as key in std::map. */
        int minlength = std::min(b1.getSize(), b2.getSize());
        for (int i = 0; i < minlength; i++) {
            if (b1.bytes[i] != b2.bytes[i]) {
                return b1.bytes[i] < b2.bytes[i];
            }
        }
        return b1.getSize() < b2.getSize();
    }

    void noRelease(infinispan::hotrod::ScopedBuffer*) { /* nothing allocated, nothing to release */ }

    template<> class BasicMarshaller<ByteArray>: public infinispan::hotrod::Marshaller<ByteArray> {
        void marshall(const ByteArray& barray, infinispan::hotrod::ScopedBuffer& sbuf) {
            if (barray.getSize() == 0) {
                return;
            }
            sbuf.set((char *) barray.getBytes(), barray.getSize(), &infinispan::hotrod::noRelease);
        }

        ByteArray* unmarshall(const infinispan::hotrod::ScopedBuffer& sbuf) {
            int size = sbuf.getLength();
            unsigned char *bytes = new unsigned char[size];
            memcpy(bytes, sbuf.getBytes(), size);

            return new ByteArray(bytes, size);
        }
    };
}}
}

%inline{
    namespace infinispan {
        namespace hotrod {
            std::vector<HR_SHARED_PTR<ByteArray> > as_vector(std::set<HR_SHARED_PTR<ByteArray> > input) {
                std::vector<HR_SHARED_PTR<ByteArray> > result;
                for (std::set<HR_SHARED_PTR<ByteArray> >::iterator it = input.begin(); it != input.end(); ++it) {
                    result.push_back(*it);
                }
                return result;
            }
        }
    }
 }

%template(RemoteByteArrayCache) infinispan::hotrod::RemoteCache<infinispan::hotrod::ByteArray, infinispan::hotrod::ByteArray>;

%template(ValueMetadataPair) std::pair<HR_SHARED_PTR<infinispan::hotrod::ByteArray>, infinispan::hotrod::MetadataValue>;
%template(ValueVersionPair) std::pair<HR_SHARED_PTR<infinispan::hotrod::ByteArray>, infinispan::hotrod::VersionedValue>;
/* %template(ByteArrayPair) std::pair<infinispan::hotrod::ByteArray, infinispan::hotrod::ByteArray>; */

%template(ByteArrayMap) std::map<HR_SHARED_PTR<infinispan::hotrod::ByteArray>, HR_SHARED_PTR<infinispan::hotrod::ByteArray> >;

%template(ByteArrayMapInput) std::map<infinispan::hotrod::ByteArray, infinispan::hotrod::ByteArray>;
/* %template(ByteArrayPairSet) std::set<ByteArrayPair>; */

%template(StringMap) std::map<std::string, std::string>;
%template(ByteArrayVector) std::vector<HR_SHARED_PTR<infinispan::hotrod::ByteArray> >;
%template(ServerConfigurationVector) std::vector<infinispan::hotrod::ServerConfiguration>;
%extend infinispan::hotrod::RemoteCacheManager {
    %template(getByteArrayCache) getCache<infinispan::hotrod::ByteArray, infinispan::hotrod::ByteArray>;
};

