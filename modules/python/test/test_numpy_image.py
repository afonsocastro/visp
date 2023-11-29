#############################################################################
#
# ViSP, open source Visual Servoing Platform software.
# Copyright (C) 2005 - 2023 by Inria. All rights reserved.
#
# This software is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# See the file LICENSE.txt at the root directory of this source
# distribution for additional information about the GNU GPL.
#
# For using ViSP with software that can not be combined with the GNU
# GPL, please contact Inria about acquiring a ViSP Professional
# Edition License.
#
# See https://visp.inria.fr for more information.
#
# This software was developed at:
# Inria Rennes - Bretagne Atlantique
# Campus Universitaire de Beaulieu
# 35042 Rennes Cedex
# France
#
# If you have questions regarding the use of this file, please contact
# Inria at visp@inria.fr
#
# This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
# WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
# Description:
# ViSP Python bindings test
#
#############################################################################

from typing import Any, List, Dict
from visp.core import ImageGray, ImageRGBA, ImageRGBf, RGBa, RGBf

import numpy as np
import pytest

def get_data_dicts() -> List[Dict[str, Any]]:
  h, w = 20, 20
  return [
    {
      'instance': ImageGray(h, w, 0),
      'base_value': 0,
      'value': 255,
      'np_value': 255,
      'shape': (h, w),
      'dtype': np.uint8
    },
    {
      'instance': ImageRGBA(h, w, RGBa(0, 50, 75, 255)),
      'base_value': RGBa(0, 50, 75, 255),
      'value': RGBa(255, 128, 0, 100),
      'np_value': np.asarray([255, 128, 0, 100], dtype=np.uint8),
      'shape': (h, w, 4),
      'dtype': np.uint8
    },
    {
      'instance': ImageRGBf(h, w, RGBf(0.0, 0.0, 0.0)),
      'base_value': RGBf(0.0, 0.0, 0.0),
      'value': RGBf(255, 0, 0),
      'np_value': np.asarray([255, 0, 0], dtype=np.float32),
      'shape': (h, w, 3),
      'dtype': np.float32

    },

  ]


def test_np_array_shape_type():
  '''
  Tests buffer definition, shape and dtype
  '''
  for test_dict in get_data_dicts():
    np_array = np.array(test_dict['instance'], copy=False)
    assert np_array.shape == test_dict['shape']
    assert np_array.dtype == test_dict['dtype']

def test_np_array_shape_type_numpy_fn():
  '''
  Tests converting to a numpy array by calling our defined function
  '''
  for test_dict in get_data_dicts():
    np_array = test_dict['instance'].numpy()
    assert np_array.shape == test_dict['shape']
    assert np_array.dtype == test_dict['dtype']

def test_np_array_replace_value():
  '''
  Tests 2D pixel indexing and correspondance between visp pixel reps and numpy reps
  '''
  for test_dict in get_data_dicts():
    vp_image = test_dict['instance']
    np_array = np.array(vp_image, copy=False)
    np_array[::2, ::2] = test_dict['np_value']
    for i in range(vp_image.getHeight()):
      for j in range(vp_image.getWidth()):
        if i % 2 == 0 and j % 2 == 0:
          assert vp_image[i, j] == test_dict['value']
          assert vp_image[-i, -j] == test_dict['value']
        else:
          assert vp_image[i, j] == test_dict['base_value']
          assert vp_image[-i, -j] == test_dict['base_value']

    with pytest.raises(RuntimeError):
      vp_image[vp_image.getHeight()]
    with pytest.raises(RuntimeError):
      vp_image[0, vp_image.getWidth()]
    with pytest.raises(RuntimeError):
      vp_image[-vp_image.getHeight() - 1]
    with pytest.raises(RuntimeError):
      vp_image[0, -vp_image.getWidth() - 1]
