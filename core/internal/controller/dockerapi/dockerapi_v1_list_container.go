package dockerapi

import (
	"context"
	"fmt"
	"xenixmail-core/api/dockerapi/v1"
	"xenixmail-core/internal/service/public"
)

func (c *ControllerV1) ListContainer(ctx context.Context, req *v1.ListContainerReq) (res *v1.ListContainerRes, err error) {
	res = &v1.ListContainerRes{}

	res.Data, err = public.DockerApiFromCtx(ctx).ListContainers(ctx)

	if err != nil {
		return nil, fmt.Errorf("failed to list containers: %w", err)
	}

	res.SetSuccess(public.LangCtx(ctx, "Success"))

	return
}
