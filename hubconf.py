# Optional list of dependencies required by the package
dependencies = ['torch']

import platform
import torch
import sys

pyver = str(sys.version_info[0]) + '.' + str(sys.version_info[1])
cudaver = torch.version.cuda

# check which wheel to download and unzip _C.so

wheel_url = {
    ('Windows', '2.7', None) : 'foo',
    ('Windows', '2.7', '9.0') : 'foo',
    ('Windows', '2.7', '10.0') : 'foo',
    ('Windows', '3.5', None) : 'foo',
    ('Windows', '3.5', '9.0') : 'foo',
    ('Windows', '3.5', '10.0') : 'foo',
    ('Windows', '3.6', None) : 'foo',
    ('Windows', '3.6', '9.0') : 'foo',
    ('Windows', '3.6', '10.0') : 'foo',
    ('Windows', '3.7', None) : 'foo',
    ('Windows', '3.7', '9.0') : 'foo',
    ('Windows', '3.7', '10.0') : 'foo',
    ('Linux', '2.7', None) : 'foo',
    ('Linux', '2.7', '9.0') : 'foo',
    ('Linux', '2.7', '10.0') : 'foo',
    ('Linux', '3.5', None) : 'foo',
    ('Linux', '3.5', '9.0') : 'foo',
    ('Linux', '3.5', '10.0') : 'foo',
    ('Linux', '3.6', None) : 'foo',
    ('Linux', '3.6', '9.0') : 'foo',
    ('Linux', '3.6', '10.0') : 'foo',
    ('Linux', '3.7', None) : 'foo',
    ('Linux', '3.7', '9.0') : 'foo',
    ('Linux', '3.7', '10.0') : 'foo',
    ('Darwin', '2.7', None) : 'foo',
    ('Darwin', '2.7', '9.0') : 'foo',
    ('Darwin', '2.7', '10.0') : 'foo',
    ('Darwin', '3.5', None) : 'foo',
    ('Darwin', '3.5', '9.0') : 'foo',
    ('Darwin', '3.5', '10.0') : 'foo',
    ('Darwin', '3.6', None) : 'foo',
    ('Darwin', '3.6', '9.0') : 'foo',
    ('Darwin', '3.6', '10.0') : 'foo',
    ('Darwin', '3.7', None) : 'foo',
    ('Darwin', '3.7', '9.0') : 'foo',
    ('Darwin', '3.7', '10.0') : 'foo',
}



from .torchvision.models.alexnet import alexnet
from torchvision.models.densenet import densenet121, densenet169, densenet201, densenet161
from torchvision.models.inception import inception_v3
from torchvision.models.resnet import resnet18, resnet34, resnet50, resnet101, resnet152
from torchvision.models.squeezenet import squeezenet1_0, squeezenet1_1
from torchvision.models.vgg import vgg11, vgg13, vgg16, vgg19, vgg11_bn, vgg13_bn, vgg16_bn, vgg19_bn
