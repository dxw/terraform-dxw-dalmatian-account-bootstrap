from ddsketch.ddsketch import BaseDDSketch
from ..mapping import (
    CubicallyInterpolatedMapping,
    LinearlyInterpolatedMapping,
    LogarithmicMapping,
)
from ..store import DenseStore

import google.protobuf


pb_version = tuple(map(int, google.protobuf.__version__.split(".")[0:2]))

if pb_version >= (3, 19, 0):
    import ddsketch.pb.ddsketch_pb2 as pb
else:
    import ddsketch.pb.ddsketch_pre319_pb2 as pb


class KeyMappingProto:
    @classmethod
    def _proto_interpolation(cls, mapping):
        if type(mapping) is LogarithmicMapping:
            return pb.IndexMapping.NONE
        if type(mapping) is LinearlyInterpolatedMapping:
            return pb.IndexMapping.LINEAR
        if type(mapping) is CubicallyInterpolatedMapping:
            return pb.IndexMapping.CUBIC

    @classmethod
    def to_proto(cls, mapping):
        """serialize to protobuf"""
        return pb.IndexMapping(
            gamma=mapping.gamma,
            indexOffset=mapping._offset,
            interpolation=cls._proto_interpolation(mapping),
        )

    @classmethod
    def from_proto(cls, proto):
        """deserialize from protobuf"""
        if proto.interpolation == pb.IndexMapping.NONE:
            return LogarithmicMapping.from_gamma_offset(proto.gamma, proto.indexOffset)
        elif proto.interpolation == pb.IndexMapping.LINEAR:
            return LinearlyInterpolatedMapping.from_gamma_offset(
                proto.gamma, proto.indexOffset
            )
        elif proto.interpolation == pb.IndexMapping.CUBIC:
            return CubicallyInterpolatedMapping.from_gamma_offset(
                proto.gamma, proto.indexOffset
            )
        else:
            raise ValueError("Unrecognized interpolation %r" % proto.interpolation)


class StoreProto:
    """Currently only supports DenseStore"""

    @classmethod
    def to_proto(cls, store):
        """serialize to protobuf"""
        return pb.Store(
            contiguousBinCounts=store.bins, contiguousBinIndexOffset=store.offset
        )

    @classmethod
    def from_proto(cls, proto):
        """deserialize from protobuf"""
        store = DenseStore()
        index = proto.contiguousBinIndexOffset
        store.offset = index
        for count in proto.contiguousBinCounts:
            store.add(index, count)
            index += 1
        return store


class DDSketchProto:
    @classmethod
    def to_proto(self, ddsketch):
        """serialize to protobuf"""
        return pb.DDSketch(
            mapping=KeyMappingProto.to_proto(ddsketch._mapping),
            positiveValues=StoreProto.to_proto(ddsketch._store),
            negativeValues=StoreProto.to_proto(ddsketch._negative_store),
            zeroCount=ddsketch._zero_count,
        )

    @classmethod
    def from_proto(cls, proto):
        """deserialize from protobuf

        N.B., The current protobuf loses any min/max/sum/avg information.
        """
        mapping = KeyMappingProto.from_proto(proto.mapping)
        negative_store = StoreProto.from_proto(proto.negativeValues)
        store = StoreProto.from_proto(proto.positiveValues)
        zero_count = proto.zeroCount
        return BaseDDSketch(
            mapping=mapping,
            store=store,
            negative_store=negative_store,
            zero_count=zero_count,
        )
