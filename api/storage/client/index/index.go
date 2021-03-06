// Copyright 2022 OnMetal authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package index

import (
	"context"
	"fmt"

	storagev1alpha1 "github.com/onmetal/onmetal-api/apis/storage/v1alpha1"
	"github.com/onmetal/poollet/api/storage/index/fields"
	"sigs.k8s.io/controller-runtime/pkg/client"
)

func ListVolumesRunningOnVolumePool(ctx context.Context, c client.Client, volumePoolName string) ([]storagev1alpha1.Volume, error) {
	volumeList := &storagev1alpha1.VolumeList{}
	if err := c.List(ctx, volumeList,
		client.MatchingFields{
			fields.VolumeSpecVolumePoolRefName: volumePoolName,
		},
	); err != nil {
		return nil, fmt.Errorf("error listing volumes running on volume pool %s: %w", volumePoolName, err)
	}

	return volumeList.Items, nil
}
