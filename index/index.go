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

	"sigs.k8s.io/controller-runtime/pkg/client"
)

type Builder []func(ctx context.Context, indexer client.FieldIndexer) error

func (b *Builder) Register(funcs ...func(ctx context.Context, indexer client.FieldIndexer) error) {
	*b = append(*b, funcs...)
}

func (b *Builder) AddToIndexer(ctx context.Context, indexer client.FieldIndexer) error {
	for _, f := range *b {
		if err := f(ctx, indexer); err != nil {
			return err
		}
	}
	return nil
}
