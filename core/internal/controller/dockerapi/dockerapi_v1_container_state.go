package dockerapi

import (
	"context"
	"xenixmail-core/internal/service/public"

	"xenixmail-core/api/dockerapi/v1"
)

func (c *ControllerV1) ContainerState(ctx context.Context, req *v1.ContainerStateReq) (res *v1.ContainerStateRes, err error) {
	res = &v1.ContainerStateRes{}

	res.Data, err = public.DockerApiFromCtx(ctx).GetContainerStats(ctx, req.ContainerID)

	res.SetSuccess(public.LangCtx(ctx, "Success"))

	return
}
